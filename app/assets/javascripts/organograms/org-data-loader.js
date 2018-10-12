var OrgDataLoader = {
    docBase: "/organogram-ajax/preview/",
    load: function (filename, infovisId) {
        $.ajax({cache: false, dataType: "json", url: this.docBase+filename,
            success : function(ret) {
                var data = ret.data;
                $.ajax({url: OrgDataLoader.docBase + "data/" + data.value + "-senior.csv",
                    success : function(seniorcsv){
                        Papa.parse(seniorcsv, {
                            header: true, delimiter: ',',
                            complete: function(seniorrows) {
                                senior = seniorrows.data;
                                $.ajax({url: OrgDataLoader.docBase + "data/" + data.value + "-junior.csv",
                                    success : function(juniorcsv){
                                        Papa.parse(juniorcsv, {
                                            header: true, delimiter: ',',
                                            complete: function(juniorrows) {
                                                junior = juniorrows.data;
                                                $('.chart .ajax-progress').remove();
                                                Orgvis.showSpaceTree(OrgDataLoader.buildTree(data.name), infovisId);
                                            }
                                        });
                                    },
                                    error: function() {
                                        OrgDataLoader.errorMessage(ret.responseText);
                                    }
                                });
                            }
                        });
                    },
                    error: function() {
                        OrgDataLoader.errorMessage(ret.responseText);
                    }
                });
            },
            error: function(ret) {
                OrgDataLoader.errorMessage(ret.responseText);
            }

        });
    },

    buildTree: function(department) {
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
                    'payfloor': (post['Actual Pay Floor (£)'] * 100 / 100).formatMoney(0),
                    'payceiling': (post['Actual Pay Ceiling (£)'] * 100 / 100).formatMoney(0),
                    'cost': (post['Salary Cost of Reports (£)'] * 100 / 100).formatMoney(0),
                    'reportsto': post['Reports to Senior Post'],
                    'senior' : true,
                    'type': 'senior_posts',
                    'role' : post['Job/Team Function'],
                    'profession' : post['Professional/Occupational Group'],
                    'email' : post['Contact E-mail'],
                    'phone' : post['Contact Phone'],
                    'notes' : post['Notes']
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

        Number.formatMoney = function(c, d, t, s){
            var n = this,
                s = s == undefined ? "&pound;" : s,
                c = isNaN(c = Math.abs(c)) ? 2 : c,
                d = d == undefined ? "." : d,
                t = t == undefined ? "," : t,
                b = n < 0 ? "-" : "",
                i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "",
                j = (j = i.length) > 3 ? j % 3 : 0;
            return s + b + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
        };

        function getSalaryRange(post){
            var floor = post["Payscale Minimum (£)"] * 100 / 100;
            var ceil = post['Payscale Maximum (£)'] * 100 / 100;

            return floor.formatMoney(0) + " - " + ceil.formatMoney(0);
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
                    'type': 'junior_posts'
                }
            };
        }

        senior.forEach(function(post, index) {
            var reportsTo = post['Reports to Senior Post'];
            if (null == hierarchy[reportsTo]){
                hierarchy[reportsTo] = [];
            }
            if (post.Name != 'Eliminated') {
                hierarchy[reportsTo].push(createSeniorPostNode(post, true));
            }
        });
        junior.forEach(function(post, index) {
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

        senior.forEach(function(post, index, array) {
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
            }

            var fakeNode = createSeniorPostNode(fake);
            fakeNode.children = [];

            topLevel.forEach(function(id, index, array) {
                fakeNode.children.push(tree[id]);
            })

            tree.push(fakeNode);

            return tree[tree.length - 1]
        }
    },
    errorMessage: function (message){
        $('.field-name-field-organogram .form-type-managed-file').append('<div class="alert alert-block alert-danger"><a class="close" data-dismiss="alert" href="#">×</a><h4 class="element-invisible">Error message</h4>'
            + message +'</div>');
    }
};
