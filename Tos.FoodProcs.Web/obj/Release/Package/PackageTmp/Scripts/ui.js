//dialog
(function (global, $, undef) {

    $.widget("aw.dlg", {

        options: {
            url: "",
            name: "",
            closed: function (e) { }
        },

        _create: function () {
            var self = this,
                elem = self.element,
            //for IE6
                iframe = $("<iframe class='dlg-cover' style='position:absolute; top:0; left: 0; right:0; bottom: 0; z-index:10000; display:none; width:100%; height: 100%;'></iframe>"),
                root = $("<div class='dlg-overlay' style='position:absolute; top:0; left: 0; right:0; bottom: 0; z-index:10001; display:none; width:100%; height: 100%;'></div>"),
                holder = $("<div class='dlg-holder' style='width: 100%;position: absolute; z-index:10002; '></div>"),
                height = elem.height();

            holder.hide();

            self._context = {
                open: false,
                root: root,
                iframe: iframe,
                holder: holder,
                height: height,
                name: self.options.name,
                url: self.options.url
            };

            holder.css("top", "0");
            elem.css("position", "relative");
            elem.css("margin", "0 auto");

            $(document.body).append(iframe);
            $(document.body).append(root);
            $(document.body).append(holder);

            setTimeout(function () {
                elem[0].parentNode.removeChild(elem[0]);
                holder[0].appendChild(elem[0]);
            }, 0);
        },

        open: function (opts) {
            var self = this,
                ctx = self._context;
            if (!App.isUndefOrNull(ctx._mutex) && ctx._mutex == true) {
                return;
            }
            if (!ctx.urlLoaded && ctx.name && ctx.url) {
                ctx._mutex = true;
                return self._showUrl(ctx.name, ctx.url, opts);
            } else {
                ctx._mutex = true;
                return self._show(opts);
            }
        },

        // 画面内ダイアログの表示
        _show: function (opts) {
            var self = this,
                elem = self.element,
                ctx = self._context,
                defer = $.Deferred();

            if (ctx.open) {
				ctx._mutex = false;
                return;
            }
            ctx.open = true;
            //elem.css("left", "100%"); // 左からスライドインするアニメーションの場合、必要
            // ドラッグ可能にした場合、前回の座標を覚えているのでリセットする
            elem.css("left", "0");
            elem.css("top", "0");

            ctx.iframe.show();
            ctx.root.show();
            ctx.holder.show();

            if (ctx.urlOpend && ctx.name && ctx.url) {
                //var registerdDlg = dlgPool[ctx.name];
                var dlgInstance = self._dlgInstance;
                if (dlgInstance && App.isFunc(dlgInstance.reopen)) {
                    dlgInstance.reopen(opts);
                }
            }
            //アニメーションで色を変更した場合IE6で透過が効かなくなるためアニメーションなし
            ctx.holder.css("top", (ctx.root.height() / 2) - (ctx.height !== 0 ? ctx.height : (elem.height() / 2)));
            elem.show().promise().done(defer.resolve).fail(defer.reject);
			ctx._mutex = false;
            return defer.promise();
        },

        _showUrl: function (name, url, opts) {
            var self = this,
                ctx = self._context,
                elem = self.element;

            $(self.element).load(url, function (result) {
                ctx.urlLoaded = true;
                App.ui.pagedata.lang.applySetting(App.ui.page.lang, self.element);
                setTimeout(function () {
                    self._show().done(function () {
                        ctx.urlOpend = true;
                        var registerdDlg = dlgPool[name],
                            dlgInstance;
                        if (!registerdDlg) {
                            return;
                        }
                        dlgInstance = new registerdDlg();
                        self._dlgInstance = dlgInstance;
                        if (!App.isFunc(dlgInstance.initialize)) {
                            return;
                        }
                        dlgInstance.initialize({
                            element: self.element,
                            close: function (result) {
                                self.close(result);
                            },
                            data: opts
                        });
                    });
                }, 0);

            });
        },

        close: function (result) {
            var self = this,
                elem = self.element,
                ctx = self._context;

            if (!ctx.open) {
                return;
            }
            ctx.open = false;
            elem.hide().promise().done(function () {
                //アニメーションで色を変更した場合IE6で透過が効かなくなるためアニメーションなし
                ctx.holder.hide();
                ctx.root.hide();
                ctx.iframe.hide();

                self._trigger("closed", null, result);
            });
        }

    });

    var dlgPool = {},
        instantiatable = function (obj) {
            var dlgClass = function () {
            };
            dlgClass.prototype = obj;
            return dlgClass;
        }

    $.dlg = {
        register: function (name, obj) {
            if (!(name in dlgPool)) {
                dlgPool[name] = instantiatable(obj);
            }
        }
    }
})(this, jQuery);

(function (global, $, undef) {

    var ddlmenu = App.define("App.ui.ddlmenu", {

        setting: {},
        isShowed: false,
        context: {},
        settings: function(lang, title, setting) {
            ddlmenu.settingsObj[lang] = {
                title: title, 
                setting: setting
            };
        },

        settingsObj : {},

        setup: function (lang, role, container) {
            
            ddlmenu.setting = ddlmenu.settingsObj[lang] || {setting: [], title: ""};
            //ddlmenu.context.options = options;

            role = App.ifUndefOrNull(role, "");

            var root = createItemsElement(ddlmenu.setting.setting || [], 1001, role);
            root.addClass("ddl-menu");

            root.find("a").on("hover", function() {
                var self = $(this);
                root.children("li").find("ul").hide();
                self.parents("ul").show();
                self.parents("li").children("ul").show();
            });

            $(container).append(root);
        }
    });

    var isVisibleRole = function(item, role) {

        var visible = false, 
            i;

        if (!item.visible) {
            return true;
        }

        // visible が "*" 以外の文字列で指定されていて、 role と一致しない場合は表示しない
        if(App.isStr(item.visible) && item.visible !== "*" && item.visible !== role){
            return visible;
        }
        // visible が 配列で role とどれも一致しない場合は表示しない
        else if(App.isArray(item.visible)){
            
            for(i = 0; i < item.visible.length; i++){
                if(item.visible[i] === role){
                    visible = true;
                    break;
                }
            }

            return visible;
        }
        // visible が 関数で戻り値が false の場合は表示しない
        else if(App.isFunc(item.visible)) {
            return item.visible(role);
        }

        return true;
    };

    var createItemsElement = function (items, zIndex, role) {
        
        var ul = $("<ul></ul>"),
            li,
            i,
            item;

        for (i = 0; i < items.length; i++) {
            
            item = items[i];
            if ( !isVisibleRole(item, role) ) {
                continue;
            }

            li = $("<li></li>");

            if (item.items && item.items.length) {
                li.append("<a href='" + (item.url ? item.url : "#") + "'>" + item.display + "<span></span></a>");
                li.append(createItemsElement(item.items, zIndex, role));
            } 
            else if (item.url) {
                li.append("<a href='" + item.url + "'>" + item.display + "</a>");
            }

            ul.append(li);
        }

        return ul;
    };

})(this, jQuery);

//pagedata
(function (global, $, undef) {
    
    var pagedata = App.define("App.ui.pagedata"),
        settings = {
            defaultLangSetting: void 0,
            langSettings: {},
            defaultValidationSetting: void 0,
            validationSettings: {},
            defaultOperationSetting: void 0,
            operationSettings: {}
        },
        setup = function(defSettingName, settingsName, lang, setting){
            var newSetting;
            if(arguments.length === 2){
                return settings[defSettingName];
            } else if(arguments.length === 3){
                if(App.isStr(lang)){
                    return settings[settingsName][lang];
                }else{
                    settings[defSettingName] = lang;
                    return lang;
                }
            } else if(arguments.length === 4){
                 newSetting = $.extend({}, settings[settingsName][lang] || {}, setting);
                 settings[settingsName][lang] = newSetting;
                 return newSetting;
            }
        };


    pagedata.lang = function(lang, setting){
        return setup.apply(null,["defaultLangSetting", "langSettings"].concat(Array.prototype.slice.call(arguments)));
    };
    pagedata.validation = function(lang, setting){
        return setup.apply(null,["defaultValidationSetting", "validationSettings"].concat(Array.prototype.slice.call(arguments)));
    };
    pagedata.validation2 = function(lang, setting){
        return setup.apply(null,["defaultValidationSetting", "validationSettings"].concat(Array.prototype.slice.call(arguments)));
    };
    pagedata.validation3 = function(lang, setting){
        return setup.apply(null,["defaultValidationSetting", "validationSettings"].concat(Array.prototype.slice.call(arguments)));
    };
    pagedata.validation4 = function(lang, setting){
        return setup.apply(null,["defaultValidationSetting", "validationSettings"].concat(Array.prototype.slice.call(arguments)));
    };
    pagedata.operation = function(lang, setting){
        return setup.apply(null,["defaultOperationSetting", "operationSettings"].concat(Array.prototype.slice.call(arguments)));
    };

    pagedata.lang.applySetting = function(lang, root){
        var setting = $.extend({}, settings.defaultLangSetting || {}, settings.langSettings[lang] || {}),
            namedElems = root ? $(root).find("[name]"): $("[name]"),
            textElems = root ? $(root).find("[data-app-text]"): $("[data-app-text]"),
            appliedTextElems = $(),
            p, i, l, targetElem, targetElemItem, text, attrVal,
            removeChildTextNode = function(node){
                var children, i, l;
                node = node[0];
                for(i = 0, l = node.childNodes.length; i < l; i++){
                    if(node.childNodes[i] && node.childNodes[i].nodeType === 3){ //TextNode
                        node.removeChild(node.childNodes[i]);
                    }
                }
            },
            applyText = function(elem, text, attr){
                elem = $(elem);
                text = App.ifUndefOrNull(text, "");
                if(attr){
                    elem.attr(attr, text);
                }else{
                    attr = elem.is("input, select, textarea") ? "value" : "text";
                    if (attr === "text") {
                        if (elem.children().length > 0) {
                            removeChildTextNode(elem);
                            elem.append(document.createTextNode(text));
                        } else {
                            elem.text(text);
                        }
                    } else if (attr === "value") {
                        elem.val(text);
                    }
                }
            };

        for(p in setting){
            if(!setting.hasOwnProperty(p)){
                continue;
            }
            //プロパティ名に一致する data-app-text 属性の値を持つ要素と
            //name の値が一致して、かつ data-app-text 属性を持たない要素
            targetElem = textElems.filter("[data-app-text='" + p + "']"); //.add(namedElems.filter("[name='" + p + "']").not("[data-app-text]")); 
            appliedTextElems = appliedTextElems.add(targetElem);
            for(i = 0, l = targetElem.length; i < l; i++){
//                applyText(targetElem[i], setting[p].text);
                applyText(targetElem[i], setting[p].text.replace(/<br>/, " "));
            }
        }
        targetElem = textElems.not(appliedTextElems);
        for(i = 0, l = targetElem.length; i < l; i++){
            targetElemItem = $(targetElem[i]);
            attrVal = App.ifUndefOrNull(targetElemItem.attr("data-app-text"), "").split(":");
            if(attrVal.length > 1){
                applyText(targetElem[i], setting[attrVal[1]] ? setting[attrVal[1]].text : "", attrVal[0]);
            }else{
                applyText(targetElem[i], setting[attrVal[0]] ? setting[attrVal[0]].text : "");
            }
        }

        //title 要素は属性を持てないため、_pageTitle というプロパティは固定的にウィンドウタイトルとして設定する
        if(setting["_pageTitle"]){
            document.title = App.ifUndefOrNull(setting["_pageTitle"].text + setting["_commonPageTitle"].text, "");
        }
    };

    pagedata.operation.applySetting = function(role, lang, root){
        var setting = $.extend(true, {}, settings.defaultOperationSetting || {}, settings.operationSettings[lang] || {}),
            namedElems = root ? $(root).find("[name]"): $("[name]"),
            opElems = root ? $(root).find("[data-app-operation]"): $("[data-app-operation]"),
            p, i, l, targetElem, targetElemItem, item,
            pWith, type, key, child;

        for(p in setting){
            if(!setting.hasOwnProperty(p)){
                continue;
            }
            item = setting[p][role];
            if(!item){
                continue;
            }
            
            pWith = p.split(":");
            type = "";
            child = "";
            if(pWith.length > 1){
                type = pWith[0];
                p = pWith[1];
            }
            pWith = p.split(".");
            if(pWith.length > 1){
                p = pWith[0];
                child = pWith[1];
            }

            targetElem = opElems.filter("[data-app-operation='" + p + "']").add(namedElems.filter("[name='" + p + "']").not("[data-app-operation]")); 
            for(i = 0, l = targetElem.length; i < l; i++){
                targetElemItem = $(targetElem[i]);
                if(type === "grid") { //grid only
                    if(!child) continue;
                    if("enable" in item){
                        targetElemItem.jqGrid("setColProp", child, {
                             editable: !!item.enable
                        });
                    }
                    if("visible" in item){
                        targetElemItem.jqGrid(item.visible ? "showCol" : "hideCol", child);
                    }
                }else{
                    if("enable" in item){
                        if(item.enable){
                            targetElem.removeAttr("disabled");
                        }else{
                            targetElem.attr("disabled", "disabled");
                        }
                    }
                    if("visible" in item){
                        if(item.visible){
                            targetElemItem.show();
                        }else{
                            targetElemItem.css("display", "none");
                        }
                    }
                }
            }
        }
    };
})(this, jQuery);

//notify
(function (global, $, undef) {

    var notify = App.define("App.ui.notify"),
        alertNotifySetting = {
            containerClass: "alert-notify",
            textContainerClass: "alert-notify-text",
            labelClass: "error",
            clickableClass: "alert-clickable",
            targetElemData: "alert-target",
            targetElemClass: "error",
            defaultTimeout: 0
        },
        infoNotifySetting = {
            containerClass: "info-notify",
            textContainerClass: "info-notify-text",
            labelClass: "info",
            clickableClass: "info-clickable",
            targetElemData: "info-target",
            targetElemClass: "info",
            defaultTimeout: 3000
        },
        setupSlideUpMessage = function (root, opts, notifySetting) {
            var root = $(root ? root : document.body),
                container,
                messagesContainer,
                clearTimeoutId = 0,
                notifyObj,
                titleHolder = $("<div class='notify-title-holder'>" +
                    "<div class='notify-title-open ui-icon ui-icon-carat-1-s' style='display:inline-block;'></div>" +
                    "<div class='notify-title-close ui-icon ui-icon-carat-1-e' style='display:none;'></div>" +
                    "<p class='notify-title-message-length' style='display:inline-block;'></p>" +
                    "<p class='notify-title-message' style='display:inline-block;'></p>" +
                    "</div>"),
                settings = {
                    container: "<div class='notify " + notifySetting.containerClass + "' style='display:none;'><ul></ul></div>",
                    messagesContainerQuery: "ul",
                    textContainer: "<li class='" + notifySetting.textContainerClass + "'></li>",
                    show: function () { },
                    clear: function () { }
                },
                closeButton = titleHolder.find(".notify-title-close"),
                openButton = titleHolder.find(".notify-title-open"),
                titleMessageLength = titleHolder.find(".notify-title-message-length"),
                hasTitle = false;

            settings = $.extend({}, settings, opts);
            container = $(settings.container);
            titleHolder.insertBefore(container.children(":first"));
            if (container.attr("title")) {
                titleHolder.find(".notify-title-message").text(container.attr("title"));
                hasTitle = true;
                container.attr("title", "");
            }
            messagesContainer = container.find(settings.messagesContainerQuery);
            if (container.parent().length < 1) {
                root.append(container);
            }

            titleHolder.on("click", function () {
                if (closeButton.css("display") === "none") {
                    messagesContainer.hide();
                    closeButton.css("display", "inline-block");
                    openButton.css("display", "none");
                } else {
                    messagesContainer.show();
                    closeButton.css("display", "none");
                    openButton.css("display", "inline-block");
                }
            });

            notifyObj = {
                message: function (text, unique) {
                    var textElem, self = this;

                    //jquery を解除
                    if(unique && unique.jquery){
                        unique = unique[0];
                    }

                    if(unique){
                        messagesContainer.children().each(function (index, elem) {
                            var current = $(elem),
                                target = current.data(notifySetting.targetElemData);
                            if((unique.nodeType && unique == target) || unique === target){
                                current.off("click");
                                current.children().text(text);
                                textElem = current;
                            }
                        });
                    }
                    
                    if(!textElem){
                        textElem = $(settings.textContainer),
                        textElem.append("<pre class='" + notifySetting.labelClass + "'></pre>");
                        textElem.children().text(text);
                        messagesContainer.append(textElem);
                    }

                    if (unique) {
                        //if(unique.nodeType){ //if HTMLElement
                            textElem.addClass(notifySetting.clickableClass);
                            textElem.css("cursor", "pointer");
                            textElem.on("click", function () {
                                var arg = {
                                    unique: unique,
                                    handled: false
                                };
                                var a = $(self).trigger("itemselected", [arg]);
                                if(unique.nodeType && !arg.handled){
                                    unique.focus();
                                }
                            });
                            $(unique).addClass(notifySetting.targetElemClass);
                        //}
                        textElem.data(notifySetting.targetElemData, unique);


                    }
                    if (hasTitle) {
                        titleMessageLength.text(messagesContainer.children().length)
                    }

                    return notifyObj;
                },

                show: function (timeout) {
                    timeout = timeout ? timeout : notifySetting.defaultTimeout;

                    if (messagesContainer.children().length > 0) {
                        container.show("slide", { direction: "down" }, 500);
                    }

                    if (clearTimeoutId !== 0) {
                        clearTimeout(clearTimeoutId);
                    }
                    clearTimeoutId = 0;

                    if (timeout > 0) {
                        clearTimeoutId = setTimeout(function () {
                            notifyObj.clear(true);
                        }, timeout);
                    }
                    if (App.isFunc(settings.show)) {
                        settings.show();
                    }
                    return notifyObj;
                },

                remove: function(unique) {
                    
                    //jquery を解除
                    if(unique && unique.jquery){
                        unique = unique[0];
                    }

                    messagesContainer.children().each(function (index, elem) {
                        var current = $(elem),
                            target = current.data(notifySetting.targetElemData);
                        if(unique){
                            if((unique.nodeType && unique == target)){
                                current.css("cursor", "default");
                                current.off("click");
                                $(unique).removeClass(notifySetting.targetElemClass);
                            }
                            if((unique.nodeType && unique == target) || unique === target){
                                current.remove();
                            }
                        }else if(App.isUndef(target)){
                            current.remove();
                        }
                    });
                    if (hasTitle) {
                        titleMessageLength.text(messagesContainer.children().length)
                    }
                    if(messagesContainer.children().length < 1){
                        messagesContainer.empty();
                        container.hide();
                        messagesContainer.show();
                        if (App.isFunc(settings.clear)) {
                            settings.clear();
                        }   
                    }
                    return notifyObj;
                },

                clear: function (useAnime) {
                    messagesContainer.children().each(function (index, elem) {
                        var target = $($(elem).data(notifySetting.targetElemData));
                        target.removeClass(notifySetting.targetElemClass);
                    });

                    if (useAnime) {
                        container.hide("slide", { direction: "down" }, 200, function () {
                            messagesContainer.empty();
                            messagesContainer.show();
                        });
                    } else {
                        messagesContainer.empty();
                        container.hide();
                        messagesContainer.show();
                    }
                    if (App.isFunc(settings.clear)) {
                        settings.clear();
                    }
                    return notifyObj;
                },

                count: function() {
                    return messagesContainer.children().length;
                }
            };
            return notifyObj;
        };

    /// <summary> 情報メッセージを表示する機能を提供します。 </summary>
    /// <param name="title">タイトル</param>
    /// <param name="subtitle">サブタイトル</param>
    /// <returns>情報メッセージを表示するためのオブジェクト</returns>
    /// <remarks> 戻りで返されるオブジェクトは message / show / clear メソッドをもち、メッセージの追加、表示、削除と非表示を制御します。 </summary>
    notify.info = function (root, opts) {
        return setupSlideUpMessage(root, opts, infoNotifySetting);
    };
    /// <summary>警告メッセージを表示する機能を提供します。 </summary>
    /// <param name="title">タイトル</param>
    /// <param name="subtitle">サブタイトル</param>
    /// <returns>警告メッセージを表示するためのオブジェクト</returns>
    /// <remarks> 戻りで返されるオブジェクトは message / show / clear メソッドをもち、メッセージの追加、表示、削除と非表示を制御します。 </summary>
    notify.alert = function (root, opts) {
        return setupSlideUpMessage(root, opts, alertNotifySetting);
    };

})(this, jQuery);

// loading
(function (global, $, undef) {

    /// <summary> データ取得など長時間にわたって行われる処理の間に表示するローディングを定義します。</summary>
    var loading = App.define("App.ui.loading");

    /// <summary> ローディングを表示します。</summary>
    /// <param name="message">表示するメッセージ</summary>
    /// <param name="target">表示する要素。指定されていない場合は body 要素が利用されます。</summary>
    loading.show = function (message, target) {

        var place = !!target ? $(target) : $(global.document.body),
            loading = place.children(".loading"),
            container, overlay, info,
            position = place.css("position");
        if (loading.length > 0) {
            loading.find(".loading-message").text(message);
            return;
        }

        if (position) {
            place.css("position", "relative");
        }
        container = $("<div class='loading' style='position:" + (!!target ? "absolute" : "fixed") + "; top:0; right:0; bottom:0; left: 0; z-index:10000;'></div>");
        overlay = $("<div class='loading-overlay' style='width: 100%; height: 100%;'></div>");
        info = $("<div class='loading-holder' style='overflow: hidden;position:absolute;'><div class='loading-image'></div><div class='loading-message' unselectable='on'>" + message + "</div></div>");
        container.append(overlay);
        container.append(info);
        place.append(container);
        info.css("top", "50%");
        info.css("margin-top", -info.outerHeight() / 2);
    };

    /// <summary> ローディングのメッセージを設定します。</summary>
    /// <param name="message">表示するメッセージ</summary>
    /// <param name="target">ローディングが表示されている要素。指定されていない場合は body 要素が利用されます。</summary>
    loading.message = function (message, target) {
        var place = !!target ? $(target) : $(global.document.body),
            loading = place.children(".loading");
        if (loading.length > 0) {
            loading.find(".loading-message").text(message);
            return;
        }
    };

    /// <summary>ローディングを閉じます。</summary>
    /// <param name="target">ローディングが表示されている要素。指定されていない場合は body 要素が利用されます。</summary>
    loading.close = function (target) {
        var place = !!target ? $(target) : $(global.document.body),
            loading = place.children(".loading");
        loading.remove();
    };

})(this, jQuery);

// block
(function (global, $, undef) {

    /// <summary> 操作不可にする範囲にブロックを定義します。</summary>
    var block = App.define("App.ui.block");

    /// <summary> ブロックを表示します。</summary>
    /// <param name="target">表示する要素。指定されていない場合は body 要素が利用されます。</summary>
    block.show = function (target) {

        var place = !!target ? $(target) : $(global.document.body),
            loading = place.children(".loading"),
            container, overlay, info,
            position = place.css("position");
        
        if (position) {
            place.css("position", "relative");
        }
        container = $("<div class='loading' style='position:" + (!!target ? "absolute" : "fixed") + "; top:0; right:0; bottom:0; left: 0; z-index:10000;'></div>");
        overlay = $("<div class='loading-overlay' style='width: 100%; height: 100%;'></div>");
        info = $("<div class='loading-holder' style='overflow: hidden;position:absolute;'></div>");
        container.append(overlay);
        container.append(info);
        place.append(container);
        info.css("top", "50%");
        info.css("margin-top", -info.outerHeight() / 2);
    };

    /// <summary>ブロックを閉じます。</summary>
    /// <param name="target">ブロックが表示されている要素。指定されていない場合は body 要素が利用されます。</summary>
    block.close = function (target) {
        var place = !!target ? $(target) : $(global.document.body),
            loading = place.children(".loading");
        loading.remove();
    };

})(this, jQuery);

// page
(function (global, $, undef) {

    var page = App.define("App.ui.page");
     
    page.lang = "en";

    page.changeSet = function() {

        var stateManager = {
            changeSet: {
                created: {}, updated: {}, deleted: {}
            }, 
            /// <summary>追加状態の変更セットに変更データを追加します。</summary>
            /// <param name="selectedRowId">追加状態の変更セットに追加する変更データの行ID</param>
            /// <param name="changeData">追加状態の変更セットに追加する変更データ</param>
            addCreated: function(selectedRowId, changeData) {
                stateManager.changeSet.created[selectedRowId] = changeData;
            },
            /// <summary>追加状態の変更セットから変更データを削除します。</summary>
            /// <param name="selectedRowId">追加状態の変更セットから削除する変更データの行ID</param>
            removeCreated: function(selectedRowId) {
                if (stateManager.changeSet.created[selectedRowId]) {
                    delete stateManager.changeSet.created[selectedRowId];
                    return true;
                }
                return false;
            },
            /// <summary>変更状態の変更セットに変更データを追加します。</summary>
            /// <param name="selectedRowId">変更状態の変更セットに追加する変更データの行ID</param>
            /// <param name="celname">変更状態の変更セットで変更する列名</param>
            /// <param name="value">変更状態の変更セットで変更する値</param>
            /// <param name="changeData">変更状態の変更セットに追加する変更データ</param>
            addUpdated: function(selectedRowId, celname, value, changeData) {
                // 追加状態の変更セットにデータが存在する場合は対象列の値を変更
                if (stateManager.changeSet.created[selectedRowId]) {
                    if (stateManager.changeSet.created[selectedRowId].hasOwnProperty(celname)) {
                      stateManager.changeSet.created[selectedRowId][celname] = value;
                    }
                } else {
                    // 更新状態の変更セットにデータが存在する場合は対象列の値を変更
                    if (stateManager.changeSet.updated[selectedRowId]) {
                        if (stateManager.changeSet.updated[selectedRowId].hasOwnProperty(celname)) {
                            stateManager.changeSet.updated[selectedRowId][celname] = value;
                        }
                    // 更新状態の変更セットにデータが存在しない場合は変更データを追加
                    } else {
                        stateManager.changeSet.updated[selectedRowId] = changeData;
                    }
                }
            },
            /// <summary>変更状態の変更セットから変更データを削除します。</summary>
            /// <param name="selectedRowId">変更状態の変更セットから削除する変更データの行ID</param>
            removeUpdated: function(selectedRowId) {
                if (stateManager.changeSet.updated[selectedRowId]) {
                    delete stateManager.changeSet.updated[selectedRowId];
                    return true;
                }
                return false;
            },
            /// <summary>削除状態の変更セットに変更データを追加します。</summary>
            /// <param name="selectedRowId">削除状態の変更セットに追加する変更データの行ID</param>
            /// <param name="changeData">削除状態の変更セットに追加する変更データ</param>
            addDeleted: function(selectedRowId, changeData) {
                if (stateManager.removeCreated(selectedRowId)) {
                    return;
                } else {
                    stateManager.removeUpdated(selectedRowId);

                    // 削除状態の変更セットに変更データを追加
                    stateManager.changeSet.deleted[selectedRowId] = changeData;
                }
            },
            /// <summary>削除状態の変更セットから変更データを削除します。</summary>
            /// <param name="selectedRowId">削除状態の変更セットから削除する変更データの行ID</param>
            removeDeleted: function(selectedRowId) {
                if (stateManager.changeSet.deleted[selectedRowId]) {
                    delete stateManager.changeSet.deleted[selectedRowId];
                    return true;
                }
                return false;
            },
            /// <summary>変更がないかどうかを取得します。</summary>
            noChange: function() {
                var createdCount = 0,
                    updatedCuount = 0,
                    deletedCount = 0,
                    p;

                for (p in stateManager.changeSet.created) {
                    createdCount++;
                }

                for (p in stateManager.changeSet.updated) {
                    updatedCuount++;
                }

                for (p in stateManager.changeSet.deleted) {
                    deletedCount++;
                }

                if (createdCount === 0 && updatedCuount === 0 && deletedCount === 0) {
                    return true;
                }
                return false
            },
            /// <summary>変更セットをJSON形式の文字列で取得します。</summary>
            getChangeSet: function() {
                var obj = JSON.stringify(stateManager.getChangeSetData());
                return obj.replace(/""/g, 'null');
            },
            getChangeSetData: function() {
                var data = {
                    Created: [], Updated: [], Deleted: []
                }, p;

                for (p in stateManager.changeSet.created) {
                    if (!stateManager.changeSet.created.hasOwnProperty(p)) {
                        continue;
                    }
                    data.Created.push(stateManager.changeSet.created[p]);
                }

                for (p in stateManager.changeSet.updated) {
                    if (!stateManager.changeSet.updated.hasOwnProperty(p)) {
                        continue;
                    }
                    data.Updated.push(stateManager.changeSet.updated[p]);
                }

                for (p in stateManager.changeSet.deleted) {
                    if (!stateManager.changeSet.deleted.hasOwnProperty(p)) {
                        continue;
                    }
                    data.Deleted.push(stateManager.changeSet.deleted[p]);
                }

                return data;
            }

        }; 

        return stateManager;
    }; 

    /// <summary> 通知コントロールを設定します。</summary>
    page.setNotify = function(info, alert){
        page.notifyInfo = info;
        page.notifyAlert = alert;
    };

})(this, jQuery);

// grid
(function (global, $, undef) {
    if(!$.jgrid  || !$.jgrid .extend){
        return;
    }
    $.jgrid.extend({
        // <summary>グリッドの列のクラスを差し替える</summary>
        toggleClassRow: function(selectedRowId, className) {
            $("#" + selectedRowId).toggleClass("ui-widget-content");
            $("#" + selectedRowId).toggleClass(className);
        },
        // <summary>編集可能な次のセルを検索し、移動する</summary>
        moveNextEditable: function (iRow, iCol) {
            return this.each(function (){
                var $t = this,
                    nCol = false,
                    rowId;

                for (var i = iRow; i < $t.rows.length; i++) {
                    rowId = $($t).jqGrid("getDataIDs")[i - 1];
                    if (!$t.grid || $t.p.cellEdit !== true) { return; }
                    // 同じ行で編集可能な次のセルを検索する
                    for (var j = iCol + 1; j < $t.p.colModel.length; j++) {
                        if ($t.p.colModel[j].editable === true && $t.p.colModel[j].hidden === false
                                    && !$("#"+rowId+" td:eq("+j+")" ).hasClass("not-editable-cell")) {
                            nCol = j; break;
                        }
                    }
                    if (nCol !== false) {
                        // 同じ行で編集可能な次のセルがある場合、次のセルに移動する
                        $($t).jqGrid("editCell", i, nCol, true);
                        return;
                    } else {
                        // 同じ行で編集可能な次のセルがない場合、次の行の編集可能な先頭セルに移動する
                        iCol = 0;
                    } 
                }
            });
        },
        // <summary>編集可能な前のセルを検索し、移動する</summary>
        movePrevEditable: function (iRow, iCol) {
            return this.each(function (){
                var $t = this,
                    nCol = false,
                    rowId;

                for (var i = iRow; i > 0; i--) {
                    rowId = $($t).jqGrid("getDataIDs")[i - 1];
                    if (!$t.grid || $t.p.cellEdit !== true) { return; }
                    // 同じ行で編集可能な前のセルを検索する
                    for (var j = iCol - 1; j >= 0; j--) {
                        if ($t.p.colModel[j].editable === true && $t.p.colModel[j].hidden === false 
                                    && !$("#"+rowId+" td:eq("+j+")" ).hasClass("not-editable-cell")) {
                            nCol = j; break;
                        }
                    }
                    if (nCol !== false) {
                        // 同じ行で編集可能な前のセルがある場合、前のセルに移動する
                        $($t).jqGrid("editCell", i, nCol, true);
                        return;
                    } else {
                        // 同じ行で編集可能な前のセルがない場合、前の行の編集可能な最終セルに移動する
                        iCol = $t.p.colModel.length;
                    }
                }
            });
        },
        /// <summary>Enter キーでカーソルを移動します。 </summary>
        /// <param name="cellName">列名</param>
        /// <param name="value">項目の値</param>
        /// <param name="iRow">項目の行番号</param>
        /// <param name="iCol">項目の列番号</param>
        moveCell: function (cellName, iRow, iCol) {
            return this.each(function (){
                var $t = this,
                    inputControl = $('#' + (iRow) + '_' + cellName);

                inputControl.bind("keydown", function (e) {
                    if (e.keyCode === App.ui.keys.Tab || e.keyCode === App.ui.keys.Enter) {
                        if (!$t.grid.hDiv.loading) {
                            if (e.shiftKey) {
                                // Shift + (TabキーまたはEnterキー)の場合は、前の編集可能なセルへ移動する
                                $($t).movePrevEditable(iRow, iCol);
                            } else {
                                // TabキーまたはEnterキーが押下された場合は、次の編集可能なセルへ移動する
                                $($t).moveNextEditable(iRow, iCol);
                            }
                        } else {
                            return false;
                        }
                    }
                });
            });    
        },
        // <summary>次のセルへ移動する</summary>
        moveNextCell: function (iRow, iCol) {
            return this.each(function () {
                var $t = this,
                    nCol = false,
                    rowId;
                for (var i = iRow; i < $t.rows.length; i++) {
                    rowId = $($t).jqGrid("getDataIDs")[i - 1];
                    if (!$t.grid || $t.p.cellEdit !== true) {
                        return;
                    }
                    // 同じ行で編集可能な次のセルを検索する
                    for (var j = iCol + 1; j < $t.p.colModel.length; j++) {
                        nCol = j;
                        break;
                    }
                    if (nCol !== false) {
                        $("#" + iRow + " td:eq('" + (iCol + 1) + "')").click();
                        return;
                    }
                    else {
                        // 同じ行で編集可能な次のセルがない場合、次の行の編集可能な先頭セルに移動する
                        iCol = 0;
                    } 
                }
            });
        },
        // <summary>前のセルへ移動する</summary>
        movePrevCell: function (iRow, iCol) {
            return this.each(function () {
                var $t = this,
                    nCol = false,
                    rowId;
                for (var i = iRow; i > 0; i--) {
                    rowId = $($t).jqGrid("getDataIDs")[i - 1];
                    if (!$t.grid || $t.p.cellEdit !== true) {
                        return;
                    }
                    // 同じ行で編集可能な前のセルを検索する
                    for (var j = iCol - 1; j >= 0; j--) {
                        nCol = j;
                        break;
                    }
                    if (nCol !== false) {
                        $("#" + iRow + " td:eq('" + (iCol + 1) + "')").click();
                        return;
                    }
                    else {
                        // 同じ行で編集可能な前のセルがない場合、前の行の編集可能な最終セルに移動する
                        iCol = $t.p.colModel.length;
                    }
                }
            });
        },
        /// <summary>Enter キーでカーソルを移動します。（編集可不可関係なく） </summary>
        /// <param name="cellName">列名</param>
        /// <param name="value">項目の値</param>
        /// <param name="iRow">項目の行番号</param>
        /// <param name="iCol">項目の列番号</param>
        moveAnyCell: function (cellName, iRow, iCol) {
            return this.each(function () {
                var $t = this,
                    inputControl = $('#' + (iRow) + '_' + cellName);
                inputControl.bind("keydown", function (e) {
                    if (e.keyCode === App.ui.keys.Tab || e.keyCode === App.ui.keys.Enter) {
                        if (!$t.grid.hDiv.loading) {
                            if (e.shiftKey) {
                                $($t).movePrevCell(iRow, iCol);
                            }
                            else {
                                $($t).moveNextCell(iRow, iCol);
                            }
                        }
                        else {
                            return false;
                        }
                    }
                });
            });    
        },
        /// <summary>Enter キーでカーソルを移動します。 </summary>
        /// <param name="cellName">列名</param>
        /// <param name="value">項目の値</param>
        /// <param name="iRow">項目の行番号</param>
        /// <param name="iCol">項目の列番号</param>
//        moveCell: function (cellName, iRow, iCol) {
//            return this.each(function (){
//                var $t = this,
//                    inputControl = $('#' + (iRow) + '_' + cellName);

//                inputControl.bind("keydown", function (e) {
//                    if (e.keyCode === App.ui.keys.Tab || e.keyCode === App.ui.keys.Enter) {
//                        if (!$t.grid.hDiv.loading) {
//                            if (e.shiftKey) {
//                                // Shift + (TabキーまたはEnterキー)の場合は、前の編集可能なセルへ移動する
//                                $($t).movePrevEditable(iRow, iCol);
//                            } else {
//                                // TabキーまたはEnterキーが押下された場合は、次の編集可能なセルへ移動する
//                                $($t).moveNextEditable(iRow, iCol);
//                            }
//                        } else {
//                            return false;
//                        }
//                    }
//                });
//            });    
//        },
        /// <summary>グリッド内のドロップダウンの生成を行います。</summary>
        /// <param name="source">ドロップダウンのデータソース</param>
        /// <param name="text">表示名</param>
        /// <param name="value">項目の値</param>
        prepareDropdown: function (source, text, value) {
            var selection = {};

            if (App.isUndefOrNull(source)) {
                return;
            }
            for (var i = 0; i < source.length; i++) {
                selection[source[i][value]] = source[i][text];
            }
            return selection;
        },
        // <summary>グリッドの列のクラスを差し替える</summary>
        toggleClassRow: function(selectedRowId, className) {
            $("#" + selectedRowId).toggleClass("ui-widget-content");
            $("#" + selectedRowId).toggleClass(className);
        },
        // <summary>グリッドのカラムのクラスを差し替える</summary>
        toggleClassCol: function(selectedRowId, cellId, className) {
            if ($("#" + selectedRowId) && $("#" + selectedRowId)[0]) {
                $("#" + selectedRowId)[0].cells[cellId].className = className;
            }
            else {
                this[0].grid.cols[cellId].className = className;
            }
        },
        // <summary>グリッドのカラムのクラスを削除する</summary>
        deleteColumnClass: function(selectedRowId, columnName, className) {
            var tr = this[0].rows.namedItem(selectedRowId),
                td = tr.cells[this.getColumnIndexByName(columnName)];
            $(td).removeClass("not-editable-cell");
        },
        // <summary>グリッドのカラムインデックスをカラム名より取得する</summary>
        getColumnIndexByName: function(columnName) {
            var cm = $(this).jqGrid('getGridParam','colModel');
            for (var i=0,l=cm.length; i<l; i++) {
                if (cm[i].name === columnName) {
                    return i;
                }
            }
            return -1;
        }

    });
})(this, jQuery);

//option タグの追加
// ui
(function (global, $, undef) {

    /// <summary>
    /// 画面に関する共通関数を定義します。
    /// </summary>
    App.define("App.ui", {

        /// <summary>
        /// 指定された select コントロールに対して、 option タグを作成して設定します。
        /// </summary>
        appendOptions: function (target, val, label, data, isDefaultOption, filter) {
            var $control = target;
            // 文字列の場合には name 属性でセレクタを作成します。
            if (App.isStr(target)) {
                $control = $("[name=" + target + "]");
            }

            if (isDefaultOption) {
                App.ui.appendDefaultOption($control);
            }

            $.each(data, function (index, option) {
                if (!App.isUndefOrNull(filter) && filter.length > 0) {
                    for (var i = 0; filter.length >i; i++) {
                        if (filter[i] == option[val]) {
                            $control.append("<option value='" + option[val] + "'>" + option[label] + "</option>");
                        }
                    }
                } else {
                    $control.append("<option value='" + option[val] + "'>" + option[label] + "</option>");
                }
            });
        },

        /// <summary>
        /// 指定された select コントロールに対して、 option タグを作成して設定します。
        /// </summary>
        appendDefaultOption: function (target) {

            var $control = target;

            // 文字列の場合には name 属性でセレクタを作成します。
            if (App.isStr(target)) {
                $control = $("[name=" + target + "]");
            }

            $control.append("<option value=''></option>");
        },

        // キーコード
        keys: {
            F1: 112,
            F2: 113,
            F3: 114,
            F4: 115,
            F5: 116,
            F6: 117,
            F7: 118,
            F8: 119,
            F9: 120,
            F10: 121,
            F11: 122,
            F12: 123,
            BS: 8,
            Enter: 13,
            Tab: 9
        }
    });
})(window, jQuery);

