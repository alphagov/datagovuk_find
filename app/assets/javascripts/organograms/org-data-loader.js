var OrgDataLoader = {
    load: function (csvURL, organogramContainer) {
        var seniorCSVURL = csvURL.replace(/-(senior|junior).csv$/, "-senior.csv");
        var juniorCSVURL = csvURL.replace(/-(senior|junior).csv$/, "-junior.csv");

        $.ajax({url: seniorCSVURL,
            success : function(seniorCSV){
                Papa.parse(seniorCSV, {
                    header: true, delimiter: ',',
                    complete: function(seniorRows) {
                        $.ajax({url: juniorCSVURL,
                            success : function(juniorCSV){
                                Papa.parse(juniorCSV, {
                                    header: true, delimiter: ',',
                                    complete: function(juniorRows) {
                                        $('.chart .ajax-progress').remove();

                                        var orgData = OrgDataLoader.buildTree(juniorRows.data, seniorRows.data);
                                        Orgvis.showSpaceTree(orgData, organogramContainer);
                                    }
                                });
                            },
                            error: function() {
                                OrgDataLoader.errorMessage("Failed to load the junior positions CSV");
                            }
                        });
                    }
                });
            },
            error: function() {
                OrgDataLoader.errorMessage("Failed to load the junior positions CSV");
            }
        });
    },

    buildTree: function(juniors, seniors) {
        var hierarchy = {};
        var tree = [];
        var processed = [];
        var seniorPosts = {};
        jobshare = [];

        function getChildren(postRef){
            var children = [];
            var juniorPosts = {
                id:postRef+"_"+"junior_posts",
                name:"Junior Posts",
                data:{
                    total:0,
                    fteTotal:0,
                    nodeType:'jp_parent',
                    type:'junior_posts',
                    colour:'#FFFFFF'
                },
                children:[]
            };

            if (hierarchy[postRef]){
                hierarchy[postRef].forEach(function(post, index, array) {
                    if (post.data['senior']){
                        if (post.data.reportsto != post.id) {
                            processed.push(post.id);
                            post['children'] = getChildren(post.id);
                            children.push(post);
                        }
                    } else {
                        post.data.FTE = Math.round(post.data.FTE*100)/100;
                        juniorPosts.children.push(post);
                        juniorPosts.data.fteTotal += post.data.FTE;
                    }

                });
            }
            if (juniorPosts.children.length > 0){
                juniorPosts.data.fteTotal = Math.round(juniorPosts.data.fteTotal*100)/100;
                children.push(juniorPosts);
            }
            return children;
        }

        function createSeniorPostNode(post, detectJobshare){
            var seniorPost = {
                'id':post['Post Unique Reference'],
                'name': post['Job Title'],
                'data':{
                    'heldBy': post['Name'],
                    'grade': post['Grade (or equivalent)'],
                    'function': post['Job/Team Function'],
                    'FTE': + post['FTE']*100/100,
                    'unit': post['Unit'],
                    'organisation': post['Organisation'],
                    'payfloor': formatMoney(post['Actual Pay Floor (£)'] * 100 / 100),
                    'payceiling': formatMoney(post['Actual Pay Ceiling (£)'] * 100 / 100),
                    'cost': formatMoney(post['Salary Cost of Reports (£)'] * 100 / 100),
                    'reportsto': post['Reports to Senior Post'],
                    'senior' : true,
                    'type': 'senior_posts',
                    'role' : post['Job/Team Function'],
                    'profession' : post['Professional/Occupational Group'],
                    'email' : post['Contact E-mail'],
                    'phone' : post['Contact Phone'],
                    'notes' : post['Notes'],
                    'office_region': post['Office Region']
                }
            }

            if(detectJobshare && seniorPosts[seniorPost.id]) {
                if(jobshare[seniorPost.id] == undefined) {
                    jobshare[seniorPost.id] = [];
                }
                jobshare[seniorPost.id].push(seniorPost);
                return seniorPost;
            }

            seniorPosts[seniorPost.id] = seniorPost;
            return seniorPost;
        }

        function formatMoney(number) {
            var s = "&pound;",
                c = 0,
                d = ".",
                t = ",",
                b = number < 0 ? "-" : "",
                i = parseInt(number = Math.abs(+number || 0).toFixed(c)) + "",
                j = (j = i.length) > 3 ? j % 3 : 0;

            return s + b + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(number - i).toFixed(c).slice(2) : "");
        }

        function getSalaryRange(post){
            var floor = post["Payscale Minimum (£)"] * 100 / 100;
            var ceil = post['Payscale Maximum (£)'] * 100 / 100;

            return formatMoney(floor) + " - " + formatMoney(ceil);
        }

        function createJuniorPostNode(post, index){
            var reportsto = seniorPosts[post['Reporting Senior Post']] != undefined ? seniorPosts[post['Reporting Senior Post']].name : '';
            return {
                'name': post['Generic Job Title'],
                'id': hashCode(index + "_" + post['Reporting Senior Post'] + "_" + post['Grade'] + "_" + post['Generic Job Title']),
                'data':{
                    'reportsto': reportsto,
                    'grade': post['Grade'],
                    'FTE': + post['Number of Posts in FTE'],
                    'unit': post['Unit'],
                    'payfloor': post['Payscale Minimum (£)'],
                    'payceiling': post['Payscale Maximum (£)'],
                    'salaryrange': getSalaryRange(post),
                    'profession_group': post['Professional/Occupational Group'],
                    'junior': true,
                    'nodeType': 'jp_child',
                    'type': 'junior_posts',
                    'office_region': post['Office Region']
                }
            };
        }

        function hashCode(string) {
            var hash = 0, i, chr, len;
            if (string.length === 0) return hash;
            for (i = 0, len = string.length; i < len; i++) {
                chr   = string.charCodeAt(i);
                hash  = ((hash << 5) - hash) + chr;
                hash |= 0; // Convert to 32bit integer
            }
            return hash;
        }

        seniors.forEach(function(post, index) {
            var reportsTo = post['Reports to Senior Post'];
            if (null == hierarchy[reportsTo]){
                hierarchy[reportsTo] = [];
            }
            if (post.Name != 'Eliminated') {
                hierarchy[reportsTo].push(createSeniorPostNode(post, true));
            }
        });

        juniors.forEach(function(post, index) {
            var reportsTo = post['Reporting Senior Post'];
            if (null == hierarchy[reportsTo]){
                hierarchy[reportsTo] = [];
            }
            if (post.Name != 'Eliminated') {
                hierarchy[reportsTo].push(createJuniorPostNode(post, index));
            }
        });

        //At this point hierarchy contains a map of senior posts with their reporting post and a list of
        //junior posts who report to them.
        var topLevel = [];

        seniors.forEach(function(post, index, array) {
            var postUR = post['Post Unique Reference'];
            var children = getChildren(postUR);

            if (-1 == processed.indexOf(postUR)){
                var seniorPost = createSeniorPostNode(post, false);
                seniorPost.children = children;
                tree.push(seniorPost);

                if (post['Reports to Senior Post'].toLowerCase() == 'xx' && post.Name.toLowerCase() != 'eliminated') {
                    topLevel.push(tree.length - 1);
                }
            }
        });

        if (topLevel.length == 1) {
            return tree[topLevel[0]];
        } else if (topLevel.length > 1) {
            var fake = {
                "Post Unique Reference": "XX",
                "Job Title": "Top Post",
                "Unit": "This post exists to group all top level posts under a single organogram",
                "data" : {
                    "heldBy" : "abc"
                }
            };

            var fakeNode = createSeniorPostNode(fake);
            fakeNode.children = [];

            topLevel.forEach(function(id, index, array) {
                fakeNode.children.push(tree[id]);
            })

            tree.push(fakeNode);

            return tree[tree.length - 1];
        }
    },

    errorMessage: function (message){
        $('.field-name-field-organogram .form-type-managed-file').append('<div class="alert alert-block alert-danger"><a class="close" data-dismiss="alert" href="#">×</a><h4 class="element-invisible">Error message</h4>'
            + message +'</div>');
    }
};
