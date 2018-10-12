var Orgvis = {
    vars: {
        debug: true,
        visOffsetX:20,
        visOffsetY:0,
        transX:0,
        transY:0,
        organogramContainer:null
    },

    log: function(info) {
      this.vars.debug && window.console && console.log && console.log(info);
    },

    showSpaceTree: function(data, organogramContainer) {
        var $organogramContainer = organogramContainer;
        $organogramContainer.css("background-image", "none");
        $organogramContainer.find(".infovis").height($(window).height()-250);
        this.vars['organogramContainer'] = $organogramContainer;

        $jit.ST.Plot.NodeTypes.implement({
            'nodeline': {
                'render': function(node, canvas, animating) {
                    if(animating === 'expand' || animating === 'contract') {
                        var pos = node.pos.getc(true), nconfig = this.node, data = node.data;
                        var width  = nconfig.width, height = nconfig.height;
                        var algnPos = this.getAlignedPos(pos, width, height);
                        var ctx = canvas.getCtx(), ort = this.config.orientation;
                        ctx.beginPath();
                        if(ort == 'left' || ort == 'right') {
                            ctx.moveTo(algnPos.x, algnPos.y + height / 2);
                            ctx.lineTo(algnPos.x + width, algnPos.y + height / 2);
                        } else {
                            ctx.moveTo(algnPos.x + width / 2, algnPos.y);
                            ctx.lineTo(algnPos.x + width / 2, algnPos.y + height);
                        }
                        ctx.stroke();
                    }
                }
            }
        });

        var spaceTree = new $jit.ST({
            'injectInto': $organogramContainer.attr("id"),
            Navigation: {
                enable: true,
                panning: 'avoid nodes',
                zooming: false
            },
            duration: 200,
            fps:30,
            orientation: 'left',
            offsetX: Orgvis.vars.visOffsetX,
            offsetY: Orgvis.vars.visOffsetY,
            transition: $jit.Trans.Quad.easeIn,
            levelDistance: 40,
            levelsToShow: 1,
            Node: {
                height:80,
                width: 170,
                type: 'nodeline',
                color:'#333333',
                lineWidth: 2,
                align:"center",
                overridable: true
            },
            Edge: {
                type: 'bezier',
                lineWidth: 2,
                color:'#DDDDDD',
                overridable: true
            },
            request: function(nodeId, level, onComplete) {
                var ans = [];//getTree(nodeId, level);
                onComplete.onComplete(nodeId, ans);
            },
            onBeforeCompute: function(node){
            },
            onAfterCompute: function(){
                $("div.node").each(function(){
                    var h = $(this).height();
                    if(h > 60){
                        //do nothing
                    } else if (h > 50){
                        $(this).css("margin-top","10px");
                    } else if (h > 35){
                        $(this).css("margin-top","15px");
                    } else {
                        $(this).css("margin-top","20px");
                    }
                });
            },
            onCreateLabel: function(label, node){
                // If the clicked node is a node and not a junior post
                if(typeof node.data != 'undefined' && node.data.type != 'junior_posts') {
                    label.id = node.id;
                    label.innerHTML = node.name;

                    if(typeof node.data.grade != 'undefined'){
                        $(label).addClass(node.data.grade);
                    }

                    if(typeof node.data.heldBy != 'undefined' && node.data.heldBy.length > 1){
                        $(label).addClass("post_"+node.data.heldBy.toLowerCase().replace(" ","_"));
                    } else {
                        $(label).addClass("post_"+node.id);
                    }

                    if(typeof node.data.unit != 'undefined' && node.data.unit.length > 0){
                        label.innerHTML = label.innerHTML + '<span class="postIn ui-state-active">'+node.data.unit+'</span>';
                    } else {
                        label.innerHTML = label.innerHTML + '<span class="postIn ui-state-active">?</span>';
                    }

                    // If the node is associated with junior posts
                } else if(node.data.type == 'junior_posts'){
                    $(label).addClass('juniorPost');
                    $(label).addClass(node.data.nodeType);

                    label.innerHTML = node.name;

                    switch (node.data.nodeType) {
                        case 'jp_child' :
                            // Node is a Junior Post
                            var fteTotal = Math.round(node.data.FTE*100)/100;
                            label.innerHTML = label.innerHTML + '<span class="jp_grade">'+node.data.salaryrange+'</span><span class="heldBy">'+fteTotal+'</span>';
                            break;

                        case 'jp_parent' :
                            // Node is a Junior Post parent
                            label.innerHTML = label.innerHTML + '<span class="heldBy">'+node.data.fteTotal+'</span>';
                            break;
                    }

                    $(label).css('color',node.data.colour);
                } else {
                    Orgvis.log("clicked something, but not sure what!");
                }

                label.onclick = function(){
                    var m = {
                        offsetX: spaceTree.canvas.translateOffsetX+Orgvis.vars.visOffsetX,
                        offsetY: spaceTree.canvas.translateOffsetY,
                        enable: true
                    };

                    if(Orgvis.vars.transX != spaceTree.canvas.canvases[0].translateOffsetX ||
                        Orgvis.vars.transY != spaceTree.canvas.canvases[0].translateOffsetY){
                        Orgvis.log("Panning has occurred");
                        Orgvis.vars.canvasPanned = true;
                        m.offsetX -= spaceTree.canvas.canvases[0].translateOffsetX;
                        m.offsetY -= spaceTree.canvas.canvases[0].translateOffsetY;
                    } else {
                        Orgvis.log("Panning has not occurred");
                    }

                    switch(node.data.type) {
                        default :
                            Orgvis.log('clicked a post node');
                            $organogramContainer.find("div.node").removeClass("selected");
                            $organogramContainer.find("#"+node.id).addClass("selected");
                            $organogramContainer.find(".infobox").hide(0,function(){
                                Orgvis.loadPostInfobox(node, $organogramContainer);
                                Orgvis.fixInfovisSize();
                            });

                            spaceTree.onClick(node.id, {
                                Move: m
                            });

                            if (Orgvis.vars.canvasPanned) {
                                spaceTree.canvas.resize($organogramContainer.width(), $organogramContainer.height());
                                Orgvis.vars.canvasPanned = false;
                            }

                            break;

                        case 'junior_posts' :
                            Orgvis.log('clicked junior_posts node');

                            switch(node.data.nodeType){
                                default :
                                    Orgvis.log('clicked junior_posts:default');
                                    $organogramContainer.find(".infobox").hide();
                                    $organogramContainer.find("div.node").removeClass("selected");
                                    $organogramContainer.find("#"+node.id).addClass("selected");
                                    spaceTree.onClick(node.id, {
                                        Move: m
                                    });

                                    if(Orgvis.vars.canvasPanned){
                                        spaceTree.canvas.resize($organogramContainer.width(), $organogramContainer.height());
                                        Orgvis.vars.canvasPanned = false;
                                    }

                                    break;

                                case 'jp_child' :
                                    // A junior post has been clicked
                                    Orgvis.log('clicked junior_posts:jp_child');

                                    $organogramContainer.find("div.node").removeClass("selected");
                                    $organogramContainer.find("#"+node.id).addClass("selected");
                                    $organogramContainer.find(".infobox").hide(0, function() {
                                        Orgvis.loadJuniorPostInfoBox(node, $organogramContainer);
                                        Orgvis.fixInfovisSize();
                                    });

                                    if(Orgvis.vars.canvasPanned){
                                        spaceTree.canvas.resize($organogramContainer.width(), $organogramContainer.height());
                                        Orgvis.vars.canvasPanned = false;
                                    }
                                    break;

                                case 'jp_none' :
                                    Orgvis.log('clicked junior_posts:jp_none');

                                    $organogramContainer.hide();
                                    $("div.jp_group_selector").hide();

                                    break;
                            }

                            break;
                    }

                };  // end label.onClick

                var style = label.style;
                style.width = 170 + 'px';
            },

            onBeforePlotNode: function(node){
                if (node.selected) {
                    node.data.$color = "ff7";
                } else {
                    delete node.data.$color;
                }
            },

            onBeforePlotLine: function(adj){
                if (adj.nodeFrom.selected && adj.nodeTo.selected) {
                    adj.data.$color = "#333333";
                    adj.data.$lineWidth = 4;
                } else {
                    delete adj.data.$color;
                    delete adj.data.$lineWidth;
                }
            }
        });

        $(window).resize(function(){
            try{
                spaceTree.canvas.resize($organogramContainer.width(), $organogramContainer.height());
            } catch(e) {
              Orgvis.log(e)
            }
        });

        spaceTree.loadJSON(data);
        spaceTree.compute();
        spaceTree.onClick(spaceTree.root);
    },

    fixInfovisSize: function() {
        var infoBoxSize = $('.infobox').height();
        var infoVisSize = $('.infovis').height();
        if ((infoVisSize - 20) < infoBoxSize ) {
            $('.infovis').height(infoBoxSize + 20);
        }
        $(window).trigger('resize');
    },

    loadPostInfobox:function(node){
        var $organogramContainer = this.vars['organogramContainer'];

        Orgvis.log("Loading post info box for " + node.name);
        Orgvis.log($organogramContainer);
        Orgvis.log(node.data);

        var postID = node.data.id;
        var postUnit, tempUnitID, tempUnitLabel;
        tempUnitID = 'tempUnitId';
        tempUnitLabel = 'TempUnitLabel';
        postUnit = 'postUnit';

        // Construct the HTML for the infobox
        var html = '<h1>'+node.name+'</h1>';
        if(node.data.heldBy != undefined && node.data.heldBy.length > 0){
            var nd = node.data;
            var scroll = jobshare[node.id] ? ' jobshare-scroll' : '';
            html += '<div class="panel heldBy ui-accordion ui-widget ui-helper-reset ui-accordion-icons' + scroll + '">';
            html += '<h3 class="ui-accordion-header ui-helper-reset ui-state-default ui-corner-all"><a class="name infobox_'+node.id+'">Name: '+nd.heldBy+'</a></h3>';
            html += '<div class="content ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom">';
            html += '<p class="unit"><span>Unit</span><span class="value">'+nd.unit+ '</span></p>';
            html += '<p class="id"><span>Post ID</span><span class="value">'+node.id+ '</span></p>';
            if(typeof nd.grade != 'undefined'){
                html += '<p class="grade"><span>Grade</span><span class="value">'+nd.grade+'</span></p>';
            }
            if(typeof nd.payfloor != 'undefined' && typeof nd.payceiling != 'undefined'){
                html += '<p class="salary"><span>Salary</span><span class="value">'+nd.payfloor+' - '+nd.payceiling+'</span></p>';
            }
            if(typeof nd.combinedSalaryOfReports != 'undefined'){
                html += '<p class="salaryReports"><span>Combined salary of reporting posts</span><span class="value">'+nd.stats.salaryCostOfReports.formatted+'</span><a class="data" target="_blank" href="http://'+Orgvis.vars.apiBase+'/doc/'+Orgvis.vars.global_typeOfOrg+'/'+Orgvis.vars.global_postOrg+'/post/'+tempID+'/statistics" value="'+nd.stats.salaryCostOfReports.value+'">Data</a><span class="date">'+nd.stats.date.formatted+'</span></p>';
            }

            if(typeof nd.role != 'undefined'){
                html += '<p class="role"><span>Role</span><span class="value">' + nd.role + '</span></p>';
            }
            if(typeof nd.profession != 'undefined'){
                html += '<p class="profession"><span>Profession</span><span class="value">' + nd.profession + '</span></p>';
            }
            if(typeof nd.FTE != 'undefined'){
                html += '<p class="fte"><span>FTE (as a fraction of a full time role)</span><span class="value">' + nd.FTE + '</span></p>';
            }
            if(typeof nd.cost != 'undefined'){
                html += '<p class="cost"><span>Combined salary of reporting posts</span><span class="value">' + nd.cost + '</span></p>';
            }
            if(typeof nd.email != 'undefined'){
                html += '<p class="email"><span>Email</span><span class="value">' + nd.email + '</span></p>';
            }
            if(typeof nd.phone != 'undefined'){
                html += '<p class="phone"><span>Phone</span><span class="value">' + nd.phone + '</span></p>';
            }
            if(typeof nd.notes != 'undefined'){
                html += '<p class="notes"><span>Notes</span><span class="value">' + nd.notes + '</span></p>';
            }
            html += '</div><!-- end content -->';

            if (jobshare[node.id]) {
                jobshare[node.id].forEach(function(sharedJob) {
                    var nd = sharedJob.data;
                    html += '<h3 class="ui-accordion-header ui-helper-reset ui-state-default ui-corner-all"><a class="name infobox_'+node.id+'">Name: '+nd.heldBy+'</a></h3>';
                    html += '<div class="content ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom">';
                    html += '<p class="unit"><span>Unit</span><span class="value">'+nd.unit+ '</span></p>';
                    html += '<p class="id"><span>Post ID</span><span class="value">'+node.id+ '</span></p>';
                    if(typeof nd.grade != 'undefined'){
                        html += '<p class="grade"><span>Grade</span><span class="value">'+nd.grade+'</span></p>';
                    }
                    if(typeof nd.payfloor != 'undefined' && typeof nd.payceiling != 'undefined'){
                        html += '<p class="salary"><span>Salary</span><span class="value">'+nd.payfloor+' - '+nd.payceiling+'</span></p>';
                    }
                    if(typeof nd.combinedSalaryOfReports != 'undefined'){
                        html += '<p class="salaryReports"><span>Combined salary of reporting posts</span><span class="value">'+nd.stats.salaryCostOfReports.formatted+'</span><a class="data" target="_blank" href="http://'+Orgvis.vars.apiBase+'/doc/'+Orgvis.vars.global_typeOfOrg+'/'+Orgvis.vars.global_postOrg+'/post/'+tempID+'/statistics" value="'+nd.stats.salaryCostOfReports.value+'">Data</a><span class="date">'+nd.stats.date.formatted+'</span></p>';
                    }

                    if(typeof nd.role != 'undefined'){
                        html += '<p class="role"><span>Role</span><span class="value">' + nd.role + '</span></p>';
                    }
                    if(typeof nd.profession != 'undefined'){
                        html += '<p class="profession"><span>Profession</span><span class="value">' + nd.profession + '</span></p>';
                    }
                    if(typeof nd.FTE != 'undefined'){
                        html += '<p class="fte"><span>FTE (as a fraction of a full time role)</span><span class="value">' + nd.FTE + '</span></p>';
                    }
                    if(typeof nd.cost != 'undefined'){
                        html += '<p class="cost"><span>Combined salary of reporting posts</span><span class="value">' + nd.cost + '</span></p>';
                    }
                    if(typeof nd.email != 'undefined'){
                        html += '<p class="email"><span>Email</span><span class="value">' + nd.email + '</span></p>';
                    }
                    if(typeof nd.phone != 'undefined'){
                        html += '<p class="phone"><span>Phone</span><span class="value">' + nd.phone + '</span></p>';
                    }
                    if(typeof nd.notes != 'undefined'){
                        html += '<p class="notes"><span>Notes</span><span class="value">' + nd.notes + '</span></p>';
                    }
                    html += '</div><!-- end content -->';
                });
            }


            html+= '</div><!-- end panel -->';
            html+= '<a class="close">x</a>';
        }

        $organogramContainer.find(".infobox").html(html);
        Orgvis.setInfoBoxLinks($organogramContainer);
        $organogramContainer.find(".infobox").show();
        $organogramContainer.find("div.heldBy").show();
    },

    loadJuniorPostInfoBox:function(node){
        var $organogramContainer = this.vars['organogramContainer'];

        Orgvis.log("Loading junior post info box for " + node.name);
        Orgvis.log($organogramContainer);
        Orgvis.log(node.data);

        // Construct the HTML for the infobox
        var nd = node.data;
        var html = '<h1>'+node.name+'</h1>';
        html += '<div class="panel ui-accordion ui-widget ui-helper-reset ui-accordion-icons">';
        html += '<div class="content ui-accordion-content ui-helper-reset ui-widget-content ui-corner-bottom ui-corner-top">';
        if(typeof nd.profession_group != 'undefined'){
            html += '<p class="profession"><span>Profession</span><span class="value">'+nd.profession_group+'</span></p>';
        }
        html += '<p class="fte"><span>Full Time Equivalent</span><span class="value">'+nd.FTE+'</span></p>';
        html += '<p class="grade"><span>Grade</span><span class="value">'+nd.grade+'</span></p>';
        html += '<p class="paybandRange"><span>Payband Salary Range</span><span class="value">'+nd.salaryrange+'</span></p>';
        html += '<p class="reportsTo"><span>Reports To</span><span class="value">'+nd.reportsto+'</span></p>';
        html += '<p class="unit"><span>Unit</span><span class="value">'+nd.unit+'</span></p>';
        html += '</div>'; // end content
        html += '</div>'; // end panel
        html += '<a class="close">x</a>';

        $organogramContainer.find(".infobox").html(html);
        Orgvis.setInfoBoxLinks($organogramContainer);
        $organogramContainer.find(".infobox").show();
        $organogramContainer.find(".infobox div.content").show();
    },
    setInfoBoxLinks: function() {
        var $organogramContainer = this.vars['organogramContainer'];
        $("a.close").click(function(){
            $(this).parent().fadeOut();
        });
        //$('div.heldBy').accordion({clearStyle:true, navigation:true, autoHeight:false, collapsible:true, active:true});
        $('.ui-state-default').mouseout(function(){$(this).removeClass('ui-state-focus')});
        $('div.panel h3').eq(0).click();
        return false;
    }
};
