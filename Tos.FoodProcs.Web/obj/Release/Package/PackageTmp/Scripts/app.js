//core
; (function (global, $, undef) {

    var define = function (name, props, root) {
        if (!name) {
            return;
        }
        var parent = root ? root : global,
            names = name.split("."),
            i = 0,
            length = names.length,
            prop;
        for (; i < length; i++) {
            parent = parent[names[i]] = parent[names[i]] || {};
        }
        if (props) {
            for (prop in props) {
                if (props.hasOwnProperty(prop)) {
                    parent[prop] = props[prop];
                }
            }
        }
        return parent;
    };


    /// <summary> 共通で利用するルートの名前空間を定義します。 </summary>
    define("App", {
        /// <summary>
        /// 名前空間(オブジェクトのプロパティチェーン)を作成します
        /// </summary>
        /// <param name="name">作成する名前空間の名前</summary>
        /// <param name="props">作成する名前空間に設定するプロパティ</summary>
        /// <param name="root">作成する名前空間が配置されるオブジェクト</summary>
        /// <returns>作成された名前空間の末端のオブジェクト</returns>
        define: define,
        /// <summary>指定された値が Object 型かどうかを取得します。</summary>
        /// <param name="target">判定する値</param>
        /// <returns> Object 型の場合は true 、そうでない場合は false </summary>
        isObj: function(target){
            return Object.prototype.toString.call(target) === "[object Object]";
        },
        /// <summary>指定された値が String 型かどうかを取得します。</summary>
        /// <param name="target">判定する値</param>
        /// <returns> String 型の場合は true 、そうでない場合は false </summary>
        isStr: function (target) {
            return Object.prototype.toString.call(target) === "[object String]";
        },
        /// <summary>指定された値が Function 型かどうかを取得します。</summary>
        /// <param name="target">判定する値</param>
        /// <returns> Function 型の場合は true 、そうでない場合は false </summary>
        isFunc: function (target) {
            return Object.prototype.toString.call(target) === "[object Function]";
        },
        /// <summary>指定された値が Array 型かどうかを取得します。</summary>
        /// <param name="target">判定する値</param>
        /// <returns> Array 型の場合は true 、そうでない場合は false </summary>
        isArray: function (target) {
            return Object.prototype.toString.call(target) === "[object Array]";
        },
        /// <summary>指定された値が Number 型かどうかを取得します。</summary>
        /// <param name="target">判定する値</param>
        /// <returns> Number 型の場合は true 、そうでない場合は false </summary>
        isNum: function (target) {
            return Object.prototype.toString.call(target) === "[object Number]";
        },
        /// <summary>指定された値が Boolean 型かどうかを取得します。</summary>
        /// <param name="target">判定する値</param>
        /// <returns> Boolean 型の場合は true 、そうでない場合は false </summary>
        isBool: function (target) {
            return Object.prototype.toString.call(target) === "[object Boolean]";
        },
        /// <summary>指定された値が Date 型かどうかを取得します。</summary>
        /// <param name="target">判定する値</param>
        /// <returns> Date 型の場合は true 、そうでない場合は false </summary>
        isDate: function (target) {
            return Object.prototype.toString.call(target) === "[object Date]";
        },
        /// <summary>指定された値が プリミティブ型(string / number / boolean)かどうかを取得します。</summary>
        /// <param name="target">判定する値</param>
        /// <returns>プリミティブ型の場合は true 、そうでない場合は false </summary>
        isPrimitive: function (target) {
            if (typeof target === "string") return true;
            if (typeof target === "number") return true;
            if (typeof target === "boolean") return true;
            return false;
        },
        isUndef: function(target){
            return typeof target === "undefined";
        },
        isUndefOrNull: function(target){
            return App.isUndef(target) || App.isNull(target);
        },
        isNull: function(target){
            return target === null;
        },
        isUnusable: function(target){
            return App.isUndef(target) || App.isNull(target) ||
                (App.isNum(target) ? isNaN(target) || !isFinite(target) : false);
        },
        isNumeric: function(target){
            return !isNaN(parseFloat(target)) && isFinite(target);
        },
        ifUndef: function(target, def){
            return App.isUndef(target) ? def : target;
        },
        ifNull: function(target, def){
            return App.ifNull(target) ? def : target;
        },
        ifUnusable: function(target, def){
            return App.isUnusable(target) ? def : target;
        },
        ifUndefOrNull: function(target, def){
            return (App.isUndef(target) || App.isNull(target)) ? def : target;
        }
    });
})(this, jQuery);

//uuid
(function (global) {
    App.uuid = function (format) {
        var rand = function (range) {
            if (range < 0) return "";
//            if (range < 0) return NaN;
            if (range <= 30) return Math.floor(Math.random() * (1 << range));
            if (range <= 53) return Math.floor(Math.random() * (1 << 30)) +
                    Math.floor(Math.random() * (1 << range - 30)) * (1 << 30);
            return "";
//            return NaN;
        },
            prepareVal = function (value, length) {
                var result = "000000000000" + value.toString(16);
                return result.substr(result.length - length);
            },
            formats = {
                "N": "{0}{1}{2}{3}{4}{5}",
                "D": "{0}-{1}-{2}-{3}{4}-{5}",
                "B": "{{0}-{1}-{2}-{3}{4}-{5}}",
                "P": "({0}-{1}-{2}-{3}{4}-{5})"
            },
            vals = [
                rand(32),
                rand(16),
                0x4000 | rand(12),
                0x80 | rand(6),
                rand(8),
                rand(48)
            ],
            result = formats[format];

        if (!result) {
            result = formats["N"];
        }
        result = result.replace("{0}", prepareVal(vals[0], 8));
        result = result.replace("{1}", prepareVal(vals[1], 4));
        result = result.replace("{2}", prepareVal(vals[2], 4));
        result = result.replace("{3}", prepareVal(vals[3], 2));
        result = result.replace("{4}", prepareVal(vals[4], 2));
        result = result.replace("{5}", prepareVal(vals[5], 12));
        return result;
    }
})(this);

// str
(function (global, $, undef) {

    App.define("App.str", {

        format: function(target){
            var args = Array.prototype.slice.call(arguments);
            args.shift();

            if (!target) {
                return target;
            }
            if (args.length === 0) {
                return target;
            }
            if (args.length === 1 && App.isArray(args[0])) {
                args = args[0];
            }
            return target.toString().replace(/\{?\{(.+?)\}\}?/g, function (match, arg1) {
                var val, splitPos, prop, rootProp, format, formatPos,
                    param = arg1;
                if (match.substr(0, 2) === "{{" && match.substr(match.length - 2) === "}}") {
                    return match.replace("{{", "{").replace("}}", "}");
                }
                
                splitPos = Math.min(param.indexOf(".") === -1 ? param.length : param.indexOf("."),
                    param.indexOf("[") === -1 ? param.length : param.indexOf("["));
                if (splitPos < param.length) {
                    rootProp = param.substr(0, splitPos);
                    prop = "['" + param.substr(0, splitPos) + "']" + param.substr(splitPos);
                } else {
                    rootProp = param;
                    prop = "['" + param + "']";
                }
                val = (new Function("return arguments[0]" + prop + ";"))(App.isNumeric(rootProp) ? args : args[0]);
                val = App.isUndef(val) ? "" : (val + "");
                if (match.substr(0, 2) === "{{") {
                    val = "{" + val;
                }
                if (match.substr(match.length - 2) === "}}") {
                    val = val + "}";
                }
                return val;
            });
        }

    });    

})(this, jQuery);

// date
(function (global, $, undef) {
    App.define("App.date", {
        /// <summary>
        /// 日付から時/分/秒/ミリ秒の値を取り除きます。
        /// </summary>
        startOfDay: function (target) {
            if (!App.isDate(target)) {
                return target;
            }
            target.setHours(0);
            target.setMinutes(0);
            target.setSeconds(0);
            target.setMilliseconds(0);
            return target;
        },
        /// <summary>
        /// 日付フォーマットの多国対応
        /// </summary>
        localDate: function(dateString){
            if (dateString == ""){
                return new Date();
            }
            if (typeof dateString === "string"
                    && dateString.match(/^\d{2}\/\d{2}\/\d{4}/) && App.ui.page.langCountry !== 'en-US'){
                var usStr = dateString.replace(/^(\d{2})\/(\d{2})\/(\d{4})/, "$2/$1/$3");
                return new Date(usStr);
            }
            return new Date(dateString);
        }
    });
})();


// rules
// TODO: 削除
(function (global, $, undef) {

    App.define("App.rules",{
    /// <summary>
    /// 指定されたルールとルール定義に基づき、項目制御を行います。
    /// ルールは複数指定することもできます。
    /// </summary>

        //指定されたルールとルール定義に基づき、項目毎に制御方法を決定します。
        //同一の項目に対して複数のルールが存在する場合は、許可されているものを優先します。
        //例）同一項目で、disable=false(編集可能)が1つでもあれば、その項目は、disable=falseとします。
        //　　同一項目で、visible=true(表示)が1つでもあれば、その項目は、visible=trueとします。
        itemControls : function(rulenames, define){
            var items ={};
            $.each(rulenames, function(i, rulename){
                $.each(define[rulename], function(name, values){
                    var rule = items[name];
                    for (value in values) {
                        if(rule === undefined || rule[value] === undefined){
                            items[name] = values;
                        }else{
                            //
                            if(value === "disable"){
                                if(values[value] === false){
                                    items[name] = values;
                                }
                            }else if(value === "visible"){
                                if(values[value] === true){
                                    items[name] = values;
                                }
                            }
                        }
                    }
                });
            });
            App.rules.itemControl(items);
        },
        
        
        //指定されたルールに基づき、項目制御の関数を呼び出します。
        itemControl : function(items){
            $.each(items, function(name, values){
                //gridの場合
                if(values.grid !== undefined){
                    if(values.disable !== undefined){
                        App.rules.gridDisable(values.grid, name, values.disable);
                    }
                    if(values.visible !== undefined){
                        App.rules.gridVisible(values.grid, name, values.visible);
                    }
                }else{
                    //grid以外の場合
                    for (value in values) {
                        App.rules[value](name, values[value]);
                    }
                }
            });
        },
        /// <summary>指定された項目に対して編集可否を制御します。 </summary>
        /// <param name="control"> 制御する項目ID </param>
        /// <param name="val"> trueの場合は編集不可、falseの場合は編集可能</param>
        disable : function(control, val){
            var item = $("[name=" + control + "]");
            if(!item) return;
            if(val == true){
                $(item).attr("disabled","disabled");
            }else{
                $(item).removeAttr("disabled");
            }

        },

        /// <summary>指定された項目に対して表示・非表示を制御します。 </summary>
        /// <param name="control"> 制御する項目ID </param>
        /// <param name="val"> trueの場合は表示、falseの場合は非表示</param>
        visible : function(control, val){
            var item = $("[name=" + control + "]");
            if(!item) return;
            if(val === true){
                $(item).show();
            }else{
                $(item).css("display", "none");
            }        
        },


        /// <summary>指定されたgrid項目に対して編集可否を制御します。 </summary>
        /// <param name="container"> gridのコンテナー名 </param>
        /// <param name="control"> 制御する項目ID </param>
        /// <param name="val">  trueの場合は編集不可、falseの場合は編集可能</param>
        gridDisable : function(container, control, val){
            $("#" +container).jqGrid("setColProp", control, {
                 editable: !val
            });
        },

        /// <summary>指定されたgrid項目に対して表示・非表示を制御します。 </summary>
        /// <param name="container"> gridのコンテナー名 </param>
        /// <param name="control"> 制御する項目ID </param>
        /// <param name="val"> trueの場合は表示、falseの場合は非表示</param>
        gridVisible : function(container, control, val){
            if(val === true){
                $("#"+container).jqGrid("showCol", control);
            }else{
                $("#"+container).jqGrid("hideCol", control);
            }
        }

    });

})(this, jQuery);

// validation
(function (global, $, undef) {

    var aw = App.define("Aw"),
        requiredRuleName = "required",
        customRuleName = "custom",
        methods = {},
        messages = {
            required: "this item required"
        },
        getMessage = function(method, item, value, param, def){
            var result;
            if(def && def.messages && (method in def.messages)){
                result = App.ifUndefOrNull(def.messages[method], "");
            }else{
                result = App.ifUndefOrNull(messages[method], "");
            }
            return App.str.format(result, param);
        },
        getMessageForCustom = function(method, item, value, param, def, pos){
            var message, result;
            if(def && def.messages && (method in def.messages)){
                message = def.messages[method];
                if(!App.isArray(message)){
                    message = [message];
                }
                result = App.ifUndefOrNull(message[pos], "");
            }else{
                result = App.ifUndefOrNull(messages[method], "");
            }
            return App.str.format(result, param);
        },
        validateItem = function(item, value, def, options){
            var result;
            if(!def.rules){
                return;
            }
            if(def.rules[requiredRuleName]){
                result = validateRequired(item, value, def, options);
            }
            if(!result){
                for(method in def.rules){
                    if(def.rules.hasOwnProperty(method) && method !== requiredRuleName && method !== customRuleName){
                        result = validateForMethod(method, item, value, def, options);
                        if(result){
                            break;    
                        }
                    }
                }
            }
            if(!result && def.rules[customRuleName]){
                result = validateCustom(item, value, def, options);
            }
            return result;
        },
        validateRequired = function(item, value, def){
            var param = def.rules[requiredRuleName];
            if(App.isUndef(value) || App.isNull(value) || (App.isStr(value) && value.length === 0)){
                if(!App.isArray(param)){
                    param = [param];
                }
                return getMessage(requiredRuleName, item, value, param, def);
            }
        },
        validateForMethod = function(method, item, value, def){
            var result, param;
            if(!def.rules){
                return;
            }
            if(def.rules && def.rules[requiredRuleName]){
                result = validateRequired(item, value, def);
            }
            if(!result){
                param = def.rules[method];
                if(!App.isFunc(methods[method])){
                    throw new Error(method + " method not defined.");
                }
                if(!methods[method](value, param)){
                    if(!App.isArray(param)){
                        param = [param];
                    }
                    result = getMessage(method, item, value, param, def);
                }
            }
            return result;
        },
        validateCustom = function(item, value, def, options){
            var result,
                i, l,
                param = options.customRuleParam,
                methods = def.rules[customRuleName],
                raiseError = function(){
                    throw new Error(customRuleName + " rule parameter should be function or function array.");
                };

            if(App.isFunc(methods)){
                methods = [methods];
            }
            if(!App.isArray(methods)){
                raiseError();
            }
            if(!param && def.params && def.params[customRuleName])
            {
                param = def.params[customRuleName];
            }
            if(!App.isArray(param)){
                param = [param];    
            }
            for(i = 0, l = methods.length; i < l; i++){
                if(App.isFunc(methods[i])){
                    if(!methods[i](value, param[i])){
                        result = getMessageForCustom(customRuleName, item, value, param[i], def, i);
                        break;
                    }
                }else{
                    raiseError();    
                }
            }
            return result;
        };

    function validator(definition, options){
        if(definition instanceof validator){
            definition = validator.def();
        }
        this._context = {
            def: definition,
            options: options
        }
    }
    $.extend(validator.prototype, {
        def: function(){
            if(!this._context) return;
            return this._context.def;
        },
        options: function(){
            if(!this._context) return;
            return this._context.options || {};
        },
        hasItem: function(itemName){
            if(!this._context) return false;
            var def = this._context.def;
            if(!def || !def.items) return false;
            return !!def.items[itemName];
        },
        validate: function(target, options){
            var result = {
                    successes: [],
                    errors: []
                }, 
                p, 
                itemsDef, 
                itemResult,
                def,
                temp;
            
            if(!this._context || !this._context.def || !this._context.def.items){
                return result;
            }
            def = this._context.def;
            itemsDef = def.items;
            options = options || {};

            // 引数が2つで第１引数が文字列の場合は、 validate("item1", "value") のように
            // 項目名と値が渡されたとみなす
            if(arguments.length === 2 && App.isStr(target)){
                temp = {};
                temp[target] = arguments[1];
                target = temp;
            }
            if(App.isUnusable(target)){
                target = {};
            }
            for(p in target){
                if(!target.hasOwnProperty(p) || !(p in itemsDef)){
                    continue;
                }
                itemResult = validateItem(p, target[p], itemsDef[p], options);
                if(itemResult){
                    result.errors.push({
                        item: p,
                        message: itemResult
                    });
                }else{
                    result.successes.push({
                        item: p
                    });
                }
            }

            if(App.isFunc(options.preReturnResult)){
                result = options.preReturnResult(result);
            }

            if(result && def.handlers && !options.suppressCallback){
                if(App.isFunc(def.handlers.success)){
                    def.handlers.success(result.successes);
                }
                if(App.isFunc(def.handlers.error)){
                    def.handlers.error(result.errors);
                }
            }
            
            return result;
        }
    });

    aw.validation = function(definition){
        if(definition instanceof validator){
            return definition;
        }
        return new validator(definition);
    };

    aw.validation.addMethod = function(name, handler, message){
        methods[name] = handler;
        if(!(name in messages)){
            messages[name] = message;
        }
    };
    
    aw.validation.setMessages = function(msgs){
        messages = $.extend({}, messages, msgs);
    };

    aw.validation.addMethod("digits", function(value, param){
        value = App.isNum(value) ? value + "" : value;
        //カンマがあったら削除
        value = value.toString();
        value = value.replace(/,/g,"");
        return ((value || "") + "") === "" || /^\d+$/.test(value);
    }, "digits only");

    aw.validation.addMethod("minlength", function(value, param){
        value = App.isNum(value) ? value + "" : value;
		var length = App.isArray( value ) ? value.length : $.trim(value).length ;
		return ((value || "") + "") === "" ||  length >= param;
    }, "at least {0} characters");
    
    aw.validation.addMethod("minbytelength", function(value, param){
        var iret = 0;		
	    for (var i = 0; i < value.length; ++i) {		
		    var c = value.charCodeAt(i);
            if ( (c >= 0x0 && c < 0x81) || (c == 0xf8f0) || (c >= 0xff61 && c < 0xffa0) || (c >= 0xf8f1 && c < 0xf8f4)) {			
			    iret = iret + 1;
		    }
            else {	
			    iret = iret + 2;
		    }	
	    }		
	    return ((value || "") + "") === "" || iret >= param;
    }, "at least {0} characters");

    aw.validation.addMethod("maxlength", function(value, param){
        value = App.isNum(value) ? value + "" : value;
		var length = App.isArray( value ) ? value.length : $.trim(value).length ;
		return ((value || "") + "") === "" ||  length <= param;
    }, "no more than {0} characters");

    aw.validation.addMethod("maxbytelength", function(value, param){
        var iret = 0;		
	    for (var i = 0; i < value.length; ++i) {		
		    var c = value.charCodeAt(i);
            if ( (c >= 0x0 && c < 0x81) || (c == 0xf8f0) || (c >= 0xff61 && c < 0xffa0) || (c >= 0xf8f1 && c < 0xf8f4)) {			
			    iret = iret + 1;
		    }
            else {	
			    iret = iret + 2;
		    }	
	    }		
	    return ((value || "") + "") === "" || iret <= param;
    }, "no more than {0} characters");
    
    aw.validation.addMethod("rangelength", function(value, param){
        value = App.isNum(value) ? value + "" : value;
		var length = App.isArray( value ) ? value.length : $.trim(value).length ;
		return ((value || "") + "") === "" ||  ( length >= param[0] && length <= param[1] );
    }, "a value between {0} and {1} characters long");

    aw.validation.addMethod("rangebytelength", function(value, param){
        var iret = 0;
	    for (var i = 0; i < value.length; ++i) {
		    var c = value.charCodeAt(i);
            if ( (c >= 0x0 && c < 0x81) || (c == 0xf8f0) || (c >= 0xff61 && c < 0xffa0) || (c >= 0xf8f1 && c < 0xf8f4)) {
			    iret = iret + 1;
		    }
            else {	
			    iret = iret + 2;
		    }	
	    }		
		return ((value || "") + "") === "" ||  ( iret >= param[0] && iret <= param[1] );
    }, "a value between {0} and {1} characters long");

    // 入力引数： value[対象数値],beforePoint[整数部の桁数],
    //            afterPoint[小数点以下桁数],minus[マイナス可不可]
    aw.validation.addMethod("pointlength", function(value, param) {
        var beforePoint = param[0];
        var afterPoint = param[1];
        var minus = param[2];
        //文字列がnullの時はtrueを返す
        value = App.isNum(value) ? value + "" : value;
        if (value == "" || App.isUndef(value) || App.isNull(value)) {
                return true;
        }
        //カンマがあったら削除
        value = value.toString();
        value = value.replace(/,/g,"");

        isPoint = false;
        if (afterPoint > 0) {
                isPoint = true;
        }
        if (!App.isNumeric(value)) {
                return false;
        }
        afterPoint = parseFloat(afterPoint);
        beforePoint = parseFloat(beforePoint);

        //小数点以下の数をチェック
        point = value.indexOf(".");
        if (point >= 0) {
                after = value.substring((point + 1));
                if (after.length > afterPoint) {
                        return false;
                }
                before = value.substring(0, point);
        }
        else {
                before = value;
        }

        //整数部分から"-"を取り除く
        if (minus && before.match(/^-/)) {
                before = before.substring(1);
        }
        //整数部分のチェック
        if (before.length > beforePoint) {
                return false;
        }
        return true;
    }, "文字数オーバーです。");

    aw.validation.addMethod("min", function(value, param){
        if(!App.isNum(value)){
            if(App.isNumeric(value)){
                value = parseFloat(value);
            }else{
                return false;
            }
        }
		return value >= param ;
    }, "a value greater than or equal to {0}");

    aw.validation.addMethod("max", function(value, param){
        if(!App.isNum(value)){
            if(App.isNumeric(value)){
                value = parseFloat(value);
            }else{
                return false;
            }
        }
		return value <= param ;
    }, "a value less than or equal to {0}");

    aw.validation.addMethod("range", function(value, param){
        if (value == "") {
            return true;
        }
        //カンマがあったら削除
        value = value.toString();
        value = value.replace(/,/g,"");
        if(!App.isNum(value)){
            if(App.isNumeric(value)){
                value = parseFloat(value);
            }else{
                return false;
            }
        }
        return value >= param[0] && value <= param[1];
    }, "a value between {0} and {1}");

    aw.validation.addMethod("date", function(value, param){
        value = App.isNum(value) ? value + "" : value;
		return ((value || "") + "") === "" ||  !/Invalid|NaN/.test(new Date(value));
    }, "a valid date");

    aw.validation.addMethod("month", function(value, param){
        value = App.isNum(value) ? value + "" : value;
		return ((value || "") + "") === "" ||   (/^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/.test(value) && value >= 1 && value <= 12);
    }, "月を入力して下さい。");
    
    aw.validation.addMethod("number", function(value, param){
        value = App.isNum(value) ? value + "" : value;
		return ((value || "") + "") === "" ||   /^-?(?:\d+|\d{1,3}(?:,\d{3})+)?(?:\.\d+)?$/.test(value);
    }, "a valid number");

    /// <summary>全角ひらがな･カタカナのみかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("kana", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return ((value || "") + "") === "" || /^([ァ-ヶーぁ-ん]+)$/.test(value);
	    }, "全角ひらがな･カタカナを入力してください"
    );

    /// <summary>全角ひらがなのみかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("hiragana", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return ((value || "") + "") === "" || /^([ぁ-ん]+)$/.test(value);
	    }, "全角ひらがなを入力してください"
    );

    /// <summary>全角カタカナのみかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("katakana", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return ((value || "") + "") === "" || /^([ァ-ヶー]+)$/.test(value);
	    }, "全角カタカナを入力してください"
    );

    /// <summary>半角文字のみで且つ半角カナが含まれていないかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("haneisukigo", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
        if(((value || "") + "") == "" ||
                (/^[a-zA-Z0-9!-\/:-@¥\[-`{-~]+$/.test(value))) { // 半角英数記号のみを許容します
            return true;
        }
        return false;
        /*
	    if (((value || "") + "") != "" &&
                (/([ァ-ヶーぁ-ん]+)/.test(value) || /([ｧ-ﾝﾞﾟ]+)/.test(value) || /([ａ-ｚーＡ-Ｚ]+)/.test(value))) {
            return false;
        }
        return true;
        */
	    }, "半角英数記号を入力してください"
    );

    /// <summary>半角カタカナのみかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("hankana", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return ((value || "") + "") === "" || /^([ｧ-ﾝﾞﾟ]+)$/.test(value);
	    }, "半角カタカナを入力してください"
    );

    /// <summary>半角アルファベット（大文字･小文字）のみかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("alphabet", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return ((value || "") + "") === "" || /^([a-zA-Z\s]+)$/.test(value);
	    }, "半角英字を入力してください"
    );

    /// <summary>半角アルファベット（大文字･小文字）もしくは数字のみかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("alphanum", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return ((value || "") + "") === "" || /^([a-zA-Z0-9]+)$/.test(value);
	    }, "半角英数字を入力してください"
    );

    /// <summary>「-」のみ許容の半角アルファベット（大文字･小文字）もしくは数字のみかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("alphanumForCode", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return value === "-" || ((value || "") + "") === "" || /^([a-zA-Z0-9]+)$/.test(value);
	    }, "半角英数字を入力してください"
    );

    /// <summary>郵便番号（例:012-3456）かどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("postnum", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return ((value || "") + "") === "" || /^\d{3}\-\d{4}$/.test(value);
	    }, "郵便番号を入力してください（例:123-4567）"
    );

    /// <summary>携帯番号（例:010-2345-6789）かどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("mobilenum", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return ((value || "") + "") === "" || /^0\d0-\d{4}-\d{4}$/.test(value);
	    }, "携帯番号を入力してください（例:010-2345-6789）"
    );

    /// <summary>電話番号（例:012-345-6789）かどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("telnum", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return ((value || "") + "") === "" || /^[0-9-]{12}$/.test(value);
	    }, "電話番号を入力してください（例:012-345-6789）"
    );

     /// <summary>fax番号（例:012-345-6789）かどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("faxnum", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
	    return ((value || "") + "") === "" || /^[0-9-]{12}$/.test(value);
	    }, "FAX番号を入力してください（例:012-345-6789）"
    );

    /// <summary>禁則文字が含まれていないかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("illegalchara", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
//	    if (((value || "") + "") != "" &&
//                ( /(["'{]+)/.test(value) )) {
//            return false;
//        }
        /* "'{} が含まれているかを検査する */
	    if (((value || "") + "") != "" &&
                ( /(["'{}]+)/.test(value) )) {
            return false;
        }
        return true;
	    //}, "特殊な文字を入力しないでください（例:'{ ）"
        }, "入力不可文字が入力されています（例:'{ ）"
    );

    /// <summary>日付文字列のバリデーションを指定します。</summary>
    aw.validation.addMethod("datestring", function (value, param) {
        if (value === "") {
            return true;
        }
        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh'){
            if (!(/^[0-9]{4}\/[0-9]{2}\/[0-9]{2}$/.test(value))) {
                    return false;
            }
        } else {
            if (!(/^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/.test(value))) {
                    return false;
            }
        }
        if (App.ui.page.langCountry == 'en-US') {
            var year = parseInt(value.substr(pageLangText.yearStartPosUS.number, 4), 10);
            var month = parseInt(value.substr(pageLangText.monthStartPosUS.number, 2), 10);
            var day = parseInt(value.substr(pageLangText.dayStartPosUS.number, 2), 10);
        } else {
            var year = parseInt(value.substr(pageLangText.yearStartPos.number, 4), 10);
            var month = parseInt(value.substr(pageLangText.monthStartPos.number, 2), 10);
            var day = parseInt(value.substr(pageLangText.dayStartPos.number, 2), 10);
        }
        var inputDate = new Date(year, month - 1, day);
        return (inputDate.getFullYear() == year && inputDate.getMonth() == month - 1 && inputDate.getDate() == day);
    }, "日付は yyyy/mm/dd の形式で入力してください");

    /// <summary>日付文字列（yyyy/mm）のバリデーションを指定します。</summary>
    aw.validation.addMethod("monthstring", function (value, param) {
        if (value === "") {
            return true;
        }
        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh'){
            if (!(/^[0-9]{4}\/[0-9]{2}$/.test(value))) {
                return false;
            }
            var year = parseInt(value.substr(0, 4), 10);
            var month = parseInt(value.substr(5, 2), 10);
        } else {
            if (!(/^[0-9]{2}\/[0-9]{4}$/.test(value))) {
                return false;
            }
            var year = parseInt(value.substr(3, 4), 10);
            var month = parseInt(value.substr(0, 2), 10);
        }
        var inputDate = new Date(year, month - 1);
        return (inputDate.getFullYear() == year && inputDate.getMonth() == month - 1);
    }, "日付は yyyy/mm の形式で入力してください");

    /// <summary>指定された値より小さいかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("lessdate", function (value, param) {
        if (!value) {
            return true;
        }
        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh'){
            if (!(/^[0-9]{4}\/[0-9]{2}\/[0-9]{2}$/.test(value))) {
                    return false;
            }
        } else {
            if (!(/^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/.test(value))) {
                    return false;
            }
        }
        if (App.ui.page.langCountry == 'en-US') {
            var year = parseInt(value.substr(pageLangText.yearStartPosUS.number, 4), 10);
            var month = parseInt(value.substr(pageLangText.monthStartPosUS.number, 2), 10);
            var day = parseInt(value.substr(pageLangText.dayStartPosUS.number, 2), 10);
        } else {
            var year = parseInt(value.substr(pageLangText.yearStartPos.number, 4), 10);
            var month = parseInt(value.substr(pageLangText.monthStartPos.number, 2), 10);
            var day = parseInt(value.substr(pageLangText.dayStartPos.number, 2), 10);
        }
        var inputDate = new Date(year, month - 1, day);
        return new Date(param.getFullYear(), param.getMonth(), param.getDate()) < inputDate;
    }, "日付は{0}以降の日付を入力してください。");

    /// <summary>指定された値より小さいかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("lessmonth", function (value, param) {
        if (!value) {
            return true;
        }
        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh'){
            if (!(/^[0-9]{4}\/[0-9]{2}$/.test(value))) {
                return false;
            }
            var year = parseInt(value.substr(0, 4), 10);
            var month = parseInt(value.substr(5, 2), 10);
        } else {
            if (!(/^[0-9]{2}\/[0-9]{4}$/.test(value))) {
                return false;
            }
            var year = parseInt(value.substr(3, 4), 10);
            var month = parseInt(value.substr(0, 2), 10);
        }
        var inputDate = new Date(year, month - 1);
        return new Date(param.getFullYear(), param.getMonth()) < inputDate;
    }, "日付は{0}以降の日付を入力してください。");

    /// <summary>指定された値より大きいかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("greaterdate", function (value, param) {
        if (!value) {
            return true;
        }
        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh'){
            if (!(/^[0-9]{4}\/[0-9]{2}\/[0-9]{2}$/.test(value))) {
                    return false;
            }
        } else {
            if (!(/^[0-9]{2}\/[0-9]{2}\/[0-9]{4}$/.test(value))) {
                    return false;
            }
        }
        if (App.ui.page.langCountry == 'en-US') {
            var year = parseInt(value.substr(pageLangText.yearStartPosUS.number, 4), 10);
            var month = parseInt(value.substr(pageLangText.monthStartPosUS.number, 2), 10);
            var day = parseInt(value.substr(pageLangText.dayStartPosUS.number, 2), 10);
        } else {
            var year = parseInt(value.substr(pageLangText.yearStartPos.number, 4), 10);
            var month = parseInt(value.substr(pageLangText.monthStartPos.number, 2), 10);
            var day = parseInt(value.substr(pageLangText.dayStartPos.number, 2), 10);
        }
        var inputDate = new Date(year, month - 1, day);
        return new Date(param.getFullYear(), param.getMonth(), param.getDate()) > inputDate;
    }, "日付は{0}以前の日付を入力してください。");

    /// <summary>指定された値より大きいかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("greatermonth", function (value, param) {
        if (!value) {
            return true;
        }
        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh'){
            if (!(/^[0-9]{4}\/[0-9]{2}$/.test(value))) {
                return false;
            }
            var year = parseInt(value.substr(0, 4), 10);
            var month = parseInt(value.substr(5, 2), 10);
        } else {
            if (!(/^[0-9]{2}\/[0-9]{4}$/.test(value))) {
                return false;
            }
            var year = parseInt(value.substr(3, 4), 10);
            var month = parseInt(value.substr(0, 2), 10);
        }
        var inputDate = new Date(year, month - 1);
        return new Date(param.getFullYear(), param.getMonth()) > inputDate;
    }, "日付は{0}以前の日付を入力してください。");

    /// <summary>指定された数値と同じ文字数かどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("equallength", function (value, param) {
        return this.optional(element) || this.getLength($.trim(value), element) === param;
    }, "{0}桁で入力してください。");

    /// <summary>半角アルファベット（大文字･小文字）、数字、記号のみかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("passwordilligalchar", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
        return ((value || "") + "") === "" || /^([a-zA-Z0-9!-\/:-@\[-`{-~]+)$/.test(value);
        }, "入力できない文字が含まれています。"
    );

    /// <summary>パスワードの複雑性のバリデーションを指定します。</summary>
    aw.validation.addMethod("passwordcomplxity", function(value, param) {
        var re = new RegExp();
	    return (value.match(/([a-zA-Z0-9])/) && value.match(/([!-\/:-@\[-`{-~])/));
        }, "パスワードには、英数字でない文字が必要です"
    );

    /// <summary>半角アルファベット（大文字･小文字）、数字、記号('"<>を除く)のみかどうかのバリデーションを指定します。</summary>
    aw.validation.addMethod("alphakigo", function(value, param) {
        value = App.isNum(value) ? value + "" : value;
        var isVali = ((value || "") + "") === "" || (/^([a-zA-Z0-9!-\/:-@\[-`{-~]+)$/.test(value));
        if (isVali) {
            // '"<>を除く
            if (value.match(/['">]/)) {
                isVali = false;
            }
        }
        return isVali;
        }, "入力できない文字が含まれています。"

	    //return ((value || "") + "") === "" || (/^([a-zA-Z0-9]+)$/.test(value) || !value.match(/['"<>]/));
        //}, "入力できない文字が含まれています。"
    );
})(this, jQuery);

// ui-validation
(function (global, $, undef) {
    
    var validatorDataKey = "awvalidator",
        targetElements = "input, select, textarea";

    function uiValidator(validator, target){
        this._context = {
            validator: validator,
            target: target
        };
    }

    $.extend(uiValidator.prototype, {
        source: function(){
            if(this._context){
                return this._context.validator;
            }
        },
        validate: function(options){
            var self, elems, elem, param = {}, elemHolder = {}, 
                i = 0, l, 
                itemName, source = this.source();
            
            if(!this._context || !this._context.target){
                return;
            }

            options = $.extend(options || {}, {
                preReturnResult: function(result){
                    var i, l, target;
                    for(i = 0, l = result.errors.length; i < l; i++){
                        target = result.errors[i];
                        target.element = elemHolder[target.item];
                    }
                    for(i = 0, l = result.successes.length; i < l; i++){
                        target = result.successes[i];
                        target.element = elemHolder[target.item];
                    }
                    return result;
                }
            });

            self = this._context.target;
            elems = self.find(targetElements);
            for(l = elems.length; i < l; i++){
                elem = $(elems[i]);
                itemName = elem.attr("name");
                if(!source.hasItem(itemName)){
                    itemName = elem.attr("data-app-validation");
                }
                if(source.hasItem(itemName)){
                    param[itemName] = elem.val();
                    elemHolder[itemName] = elem[0];
                }
            }
            return source.validate(param, options);
        }
    });

    $.fn.validation = function(define, options){
        var self = $(this),
            validator, itemName;
        options = options || {};

        if(arguments.length === 0){
            return self.data(validatorDataKey + self.selector)
        }
        
        validator = new uiValidator(Aw.validation(define, options), self);
        self.data(validatorDataKey + self.selector, validator);
        
        self.on("change", targetElements, $.proxy(function(e){
            var result,
                source = validator.source(),
                target = $(e.currentTarget),
                param = {};
            if(!source.options().batch){
                itemName = target.attr("name");
                if(!source.hasItem(itemName)){
                    itemName = target.attr("data-app-validation");
                }
                if(!source.hasItem(itemName)){
                    return;
                }
                param[itemName] = target.val();
                source.validate(param, {
                    preReturnResult: function(result){
                        if(result.successes.length){
                            result.successes[0].element = target[0];
                        }
                        if(result.errors.length){
                            result.errors[0].element = target[0];
                        }
                        return result;
                    }
                });
            }
        }, this));

        return validator;
    };

})(this, jQuery);

// deferred
(function (global, $, undef) {
    var prepare = function (value) {
        var p;
        value.key = {
            successes: [],
            fails: []
        };
        for (p in value.successes) {
            value.key.successes.push(p);
        }
        for (p in value.fails) {
            value.key.fails.push(p);
        }
        return value;
    };

    /// <summary>
    /// $.Deferred に関する拡張の機能を定義します。
    /// </summary>
    App.define("App.deferred", {
        /// <summary>指定された $.Deferred オブジェクトを並列処理する機能を提供します。</summary>
        /// <param name="args"> $.Deferred が設定されたオブジェクトまたは配列、および可変長引数で指定された各 $.Deferred </param>
        /// <returns>プロミスオブジェクト</returns>
        parallel: function (args) {

            if (arguments.length > 1) {
                args = Array.prototype.slice.call(arguments);
            }
            var deferreds = App.isArray(args) ? [] : {},
                result = {
                    successes: App.isArray(args) ? [] : {},
                    fails: App.isArray(args) ? [] : {}
                },
                hasReject = false,
                remaining = 0,
                deferred = $.Deferred(),
                updateDeferreds = function (value, key, isResolve) {
                    var res = isResolve ? result.successes : result.fails;
                    hasReject = hasReject ? true : (isResolve ? false : true);
                    res[key] = value;
                    if (!(--remaining)) {
                        if (hasReject) {
                            deferred.reject(prepare(result));
                        } else {
                            deferred.resolve(prepare(result));
                        }
                    }
                };
            $.each(args, function (index, item) {
                if ($.isFunction(item)) {
                    try {
                        item = item();
                        if (!item || !App.isFunc(item.promise)) {
                            item = $.Deferred().resolve(item);
                        }
                    } catch (e) {
                        item = $.Deferred().reject(e);
                    }
                }
                if (!item || !$.isFunction(item.promise)) {
                    item = $.Deferred().resolve(item);
                }
                if ($.isFunction(item.promise)) {
                    deferreds[index] = item;
                    remaining++;
                }
            });
            result.fails = App.isArray(deferreds) ? new Array(deferreds.length) : result.fails;

            if (remaining > 0) {
                $.each(deferreds, function (index, item) {
                    item.done(function (value) {
                        updateDeferreds(value, index, true);
                    }).fail(function (value) {
                        updateDeferreds(value, index, false);
                    });
                });
            } else {
                deferred.resolve({
                    successes: {},
                    fails: {},
                    key: {
                        successes: [],
                        fails: []
                    }
                });
            }

            return deferred.promise();
        },

        /// <summary>指定された $.Deferred オブジェクトを直列処理する機能を提供します。</summary>
        /// <param name="args"> 戻り値が $.Deferred オブジェクトとなっている関数 </param>
        /// <returns>プロミスオブジェクト</returns>
        chain: function (root) {
            var funcs = [arguments.length < 2 ? { key: 0, func: root} : { key: arguments[0], func: arguments[1]}],
            results = { successes: {}, fails: {} },
            deferr,
            exec = function (deferr, lastResult) {
                var target,
                    subdeferr;
                if (!funcs.length) {
                    deferr.resolve(prepare(results));
                    return;
                }

                target = funcs.shift();
                if (!App.isFunc(target.func)) {
                    if (App.isFunc(target.func.promise)) {
                        subdeferr = target.func;
                    } else {
                        subdeferr = $.Deferred.resolve(target.func);
                    }
                } else {
                    try {
                        subdeferr = target.func(lastResult);
                    } catch (e) {
                        results.fails[target.key] = e;
                        deferr.reject(prepare(results));
                        return;
                    }
                    if (!subdeferr || !App.isFunc(subdeferr.promise)) {
                        subdeferr = $.Deferred.resolve(subdeferr);
                    }
                }
                subdeferr.promise().done(function (result) {
                    results.successes[target.key] = result;
                    exec(deferr, result);
                }).fail(function (result) {
                    results.fails[target.key] = result;
                    deferr.reject(prepare(results));
                });
            },
            self = {
                /// <summary>指定された $.Deferred オブジェクトを直列処理する機能を提供します。</summary>
                /// <param name="args"> 戻り値が $.Deferred オブジェクトとなっている関数 </param>
                /// <returns>プロミスオブジェクト</returns>
                chain: function (func) {
                    funcs.push(arguments.length < 2 ? { key: funcs.length, func: func} : { key: arguments[0], func: arguments[1] });
                    return self;
                },
                /// <summary> $.Deferred オブジェクトの処理結果を取得するためのプロミスオブジェクトを作成します。</summary>
                /// <returns>プロミスオブジェクト</returns>
                promise: function () {
                    deferr = $.Deferred();
                    if (!funcs.length) {

                        deferr.resolve({
                            successes: {},
                            fails: {},
                            key: {
                                successes: [],
                                fails: []
                            }
                        });

                    } else {
                        exec(deferr);
                    }
                    return deferr.promise();
                },
                /// <summary> $.Deferred オブジェクトの処理が成功した場合に実行する関数を設定します。</summary>
                /// <returns>プロミスオブジェクト</returns>
                done: function (handler) {
                    return self.promise().done(handler);
                },
                /// <summary> $.Deferred オブジェクトの処理が失敗した場合に実行する関数を設定します。</summary>
                /// <returns>プロミスオブジェクト</returns>
                fail: function (handler) {
                    return self.promise().fail(handler);
                },
                /// <summary> $.Deferred オブジェクトの処理が完了した場合に実行する関数を設定します。</summary>
                /// <returns>プロミスオブジェクト</returns>
                always: function (handler) {
                    return self.promise().always(handler);
                }
            };
            return self;
        }
    });

})(window, jQuery);

// ajax
(function (global, $, undef) {

    $.ajaxSetup({
        cache: false
    });

    /// <summary>
    /// Ajax リクエストに関する関数を定義します。
    /// リクエストを実行する関数はプロミスオブジェクトを戻り値として返却するため、
    /// 複数の非同期処理の待ち合わせや順次処理などの実装が可能となります。
    /// </summary>
    var ajax = App.define("App.ajax"),
        errorMessageHandlers = [];

    var errorHandler = {
        "text/html": function (result) {
            var message = result.responseText.match(/\<title\>(.*)\<\/title\>/i);
            message = (message && message.length > 1) ? message[1] : undefined;
            return message;

        },
        "application/json": function (result) {
            var ret = JSON.parse(result.responseText),
                message = "raise error";
            if (ret.error && ret.error.message) {
                message = ret.error.message.value;
            } else if (ret.Message) {
                message = ret.Message;
            }
            return message;
        }
    };


    /// <summary>Ajax エラーの際のエラーハンドラーを追加します。 </summary>
    /// <param name="key"> エラーハンドラーのキー名 </param>
    /// <param name="handler"> 引数にメッセージ及び Ajax レスポンス、戻り値として message プロパティをもつオブジェクトを返すエラーハンドラー関数</param>
    ajax.addErrorMessageHandler = function (key, handler) {
        var i = 0,
            length = errorMessageHandlers.length,
            item;
        for (; i < length; i++) {
            item = errorMessageHandlers[i];
            if (item.key === key) {
                break;
            }
            item = undef;
        }
        if (item) {
            item.handler = handler;
        } else {
            errorMessageHandlers.push({
                key: key,
                handler: handler
            });
        }
    };

    /// <summary>Ajax エラーの際のエラーハンドラーを削除します。 </summary>
    /// <param name="key"> エラーハンドラーのキー名 </param>
    ajax.removeErrorMessageHandler = function (key) {
        var i = 0,
            length = errorMessageHandlers.length,
            index;
        for (; i < length; i++) {
            index = i;
            item = errorMessageHandlers[i];
            if (item.key === key) {
                break;
            }
            item = undef;
        }
        if (item) {
            errorMessageHandlers.splice(index, 1);
        }
    }

    var handleMessage = function (message, response) {
        var i = 0,
            length = errorMessageHandlers.length,
            handler,
            handleResult;

        if(!App.isStr(message)){
            if(typeof message === "undefined" || message == null){
                message = "";
            }
            message = message.toString();
        }

        for (; i < length; i++) {
            handler = errorMessageHandlers[i].handler;
            if (handler) {
                handleResult = handler(message, response);
                if (handleResult) {
                    return handleResult;
                }
            }
        }
        return {
            message: message,
            type: "unknown",
            level: "critical"
        };
    };

    var handleError = function (result) {
        var contentType = result.getResponseHeader("content-type"),
            mime = contentType ? contentType.split(";")[0] : contentType,
            message = "",
            messageHandleResult;

        if (mime && errorHandler[mime]) {
            message = errorHandler[mime](result);
        } else {
            if (result.statusText) {
                message = result.statusText;
            }
        }

         messageHandleResult = handleMessage(message, result);

        return {
            message: messageHandleResult.message,
            rawText: result.responseText,
            status: result.status,
            statusText: result.statusText,
            response: result,
            type: messageHandleResult.type,
            level: messageHandleResult.level
        };
    };

    var buildAjaxParams = function (source, custom, deferr) {
        return $.extend({}, {
            contentType: "application/json; charset=utf-8",
            dataType: "json"
        }, source, custom, {
            success: deferr.resolve,
            error: function (result) {
                deferr.reject(handleError(result));
            }
        });
    };

    var callAjax = function (url, data, type, header, sync) {
        var defer = $.Deferred(),
            settings = {
                url: url,
                data: data,
                headers: header,
                converters: {}
            };
        if(type === "GET"){
            settings.converters["text json"] = function(data){
                return JSON.parse(data, function(key, val){
//                    var match = /^\/?Date\((\-?\d+)/i.exec(val);
//                    if (match) {
//                        return new Date(+match[1]);
//                    }
                    return val;
                });
            }
        }
        if (sync) {
            settings.async = false;
        }
        $.ajax(buildAjaxParams(settings, {
            type: type
        }, defer));

        return defer.promise();
    };

    // webget / webput / webpost / webdelete
    /// <summary>関数名に合わせた HTTP メソッドを利用した非同期 Ajax リクエストを発行します。</summary>
    // webgetSync / webputSync / webpostSync / webdeleteSync
    /// <summary>関数名に合わせた HTTP メソッドを利用した同期 Ajax リクエストを発行します。</summary>
    // 共通
    /// <param name="url">リクエストを送信するURL</param>
    /// <param name="data">送信するデータ</param>
    /// <returns> プロミスオブジェクト </returns>
    $.each(["get", "put", "post", "delete"], function (index, item) {
        ajax["web" + item] = function (url, data) {
            var method = item;
                header = {};
            //TODO x-http-method を利用する必要がある場合はここを有効化
//            if (method === "put") {
//                method = "post";
//                header["x-http-method"] = "MERGE"
//            }
            return callAjax(url, data, method.toUpperCase(), header);
        };
        ajax["web" + item + "Sync"] = function (url, data) {
            var method = item;
                header = {};
            //TODO x-http-method を利用する必要がある場合はここを有効化
//            if (method === "put") {
//                method = "post";
//                header["x-http-method"] = "MERGE"
//            }
            return callAjax(url, data, method.toUpperCase(), header, true);
        };
    });


})(window, jQuery);

//form
(function (global, $, undef) {

    var toJSONDefaultOptions = {
            /// <summary>
            /// HTML フォーム要素の値からオブジェクトへの変換を行う際の変換を定義します。
            /// </summary>
            converters: {},     // 適用されるコンバーター
            omitNames: []       // オブジェクトに変換対象としない name を指定します。
        },
        toFormDefaultOptions = {
            appliers: {}
        };


    /// <summary>
    /// HTML 要素からオブジェクトへ変換します。
    /// </summary>
    /// <param name="options">オプション</param>
    /// <returns>
    /// 変換されたオブジェクト。
    /// </returns>
    $.fn.toJSON = function (options) {
        // 引数で受け渡されたオプションと既定の変換の定義をマージします。
        var settings = $.extend(true, {}, toJSONDefaultOptions, options),
            self = $(this),
            $controls = self.find("*").not(":button"),
            result = {};

        // HTML フォーム内のコントロールごとにオブジェクトへの変換処理を実行します。
        $.each($controls, function () {
            var $control = $(this),
                name = $control.data("formItem"),
                i;

            if (!name) {
                name = this.name;
            }
            if (!name) {
                return;
            }

            // コントロールが省略（オブジェクトへの変換を除外する）かどうかを判定します。
            // 省略される場合は処理を終了します。
            if (settings.omitNames && $.isArray(settings.omitNames)) {
                for (i in settings.omitNames) {
                    if (settings.omitNames.hasOwnProperty(i) && settings.omitNames[i] == name) {
                        return;
                    }
                }
            }

            // コントロールが input タグかどうかを判定し値を取得します。
            var value = $control.is(":input") ? $control.val() : $control.text();

            var converter = $control.data("formConverter");
            if (converter in settings.converters) {
                result[name] = settings.converters[converter]($control, value);
                return;
            }

            // name 属性をもとに適用されるコンバーターの対象になる場合はコンバーターの変換処理を適用します。
            if (name in settings.converters) {
                result[name] = settings.converters[name]($control, value);
                return;
            }

            // class 属性をもとに適用されるコンバーターの対象になる場合はコンバーターの変換処理を適用します。
            var classes = $control.attr("class");
            if (classes) {
                var classNames = classes.toString().split(" ");
                for (i = 0; i < classNames.length; i++) {
                    if (classNames[i] in settings.converters) {
                        result[name] = settings.converters[classNames[i]]($control, value);
                        return;
                    }
                }
            }

            // コントロールが checkbox, radio の場合にはチェックされていないコントロールの値を NULL に設定します。
            if ($control.is("input:checkbox") || $control.is("input:radio")) {
                if (!this.checked) {
                    if (typeof result[name] == "undefined") {
                        result[name] = null;
                    }
                    return;
                }
            }

            // 値がから文字列の場合には NULL を設定します。
            if (value == "") {
                result[name] = null;
                return;
            }

            // コンバーターによる変換処理が適用されなかった場合には値を設定します。
            result[name] = value;
        });

        // JSON オブジェクト内に日付フォーマット文字列が含まれている場合には日付型に変換します。
        // # AJAX によるサーバーへのデータ送信処理で日付型の認識をさせるため。
        $.each(result, function (index, value) {
            if (typeof value === "string"
                && value.match(/\/Date\((-?\d*)\)\//g)) {
                result[index] = (new Function("return " + value.replace(/\/Date\((-?\d*)\)\//g, "new Date($1)")))();
            }
        });

        return result;
    };

    /// <summary>
    /// オブジェクトから HTML 要素に値を設定します。
    /// </summary>
    /// <param name="data">オブジェクト</param>
    /// <param name="options">オプション</param>
    $.fn.toForm = function (data, options) {

        var self = $(this);

        // 引数で受け渡されたオプションと既定の変換の定義をマージします。
        var settings = $.extend(true, {}, toFormDefaultOptions, options);

        // オブジェクトのプロパティごとに HTML フォーム要素への値設定処理を行います。
        $.each(data, function (name, value) {

            // HTML フォーム要素から data-form-item 属性とプロパティ名が等しいコントロールを取得します。
            var $control = self.find("[data-form-item='" + name + "']");
            // コントロールが取得できなかった場合は name 属性で検索します。
            if ($control.length == 0) {
                $control = self.find("[name=" + name + "]");
            }
            // コントロールが取得できなかった場合は id 属性で検索します。
            if ($control.length == 0) {
                $control = self.find("#" + name);
            }
            // コントロールが取得できなかった場合には処理を終了します。
            if ($control.length == 0) {
                return;
            }

            $control.each(function () {
                var $target = $(this);
                var applier = $target.data("formApplier");
                if (applier && applier in settings.appliers) {
                    if (settings.appliers[applier](value, $target)) {
                        return;
                    }
                }
                if (name in settings.appliers) {
                    if (settings.appliers[name](value, $target)) {
                        return;
                    }
                }
                var classes = $target.attr("class");
                if (classes) {
                    var classNames = classes.toString().split(" ");
                    for (var i = 0; i < classNames.length; i++) {
                        if (classNames[i] in settings.appliers) {
                            if (settings.appliers[classNames[i]](value, $target)) {
                                return;
                            }
                        }
                    }
                }

                // コントロールが select の場合にはコントロールの値を設定します。
                if ($target.is("select")) {
                    if ($target.text().indexOf(value) === -1)
                    {
                        $target.val(value);
                        return;
                    }
                }

                // コントロールが checkbox, radio の場合にはコントロールの値を設定します。
                if ($target.is("input:checkbox") || $target.is("input:radio")) {
                    if (!$.isArray(value)) {
                        $target.val([value]);
                        return;
                    }
                }

                // コントロールが input タグかどうかを判定し値を設定します。
                if ($target.is(":input")) {
                    $target.val(value);
                } else {
                    if (!App.isUndefOrNull(value)) {
                        $target.text(value);
                    } else {
                        $target.text("");
                    }
                }
            });
        });

        return self;
    };

    /// <summary>
    /// data-app-formatクラス が適用されたHTML フォーム要素の値からオブジェクトへの変換を行う際の変換を定義します。
    /// </summary>
    /// <param name="element">HTML 要素</param>
    /// <param name="defaultvalue">規定値</param>
    /// <returns>
    /// 変換された結果の値。無効な場合は defaultvalue。
    /// </returns>
    toJSONDefaultOptions.converters["data-app-format"] = function (element, defaultValue) {
        if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh'){
            if (typeof defaultValue === "string"
                    && defaultValue.match(/^\d{4}\/\d{2}\/\d{2}/)) {
                    return new Date(defaultValue);
            }
        } else {
            if (typeof defaultValue === "string"
                    && defaultValue.match(/^\d{2}\/\d{2}\/\d{4}/)) {
                    if (App.ui.page.langCountry == 'en-US') {
                        return new Date(defaultValue);
                    } else {
                        var month = defaultValue.substr(pageLangText.monthStartPos.number, 2);
                        var day = defaultValue.substr(pageLangText.dayStartPos.number, 2);
                        var inputDate = month + "/" + day + defaultValue.substr(pageLangText.yearBeforePos.number);
                    }
                    return new Date(inputDate);
            }
        }
        return defaultValue;
    };

    /// <summary>
    /// オブジェクトから data-app-formatクラス が適用されたHTML フォーム要素の値変換を行う際の変換を定義します。
    /// </summary>
    /// <param name="value">オブジェクトのプロパティ値</param>
    /// <param name="element">HTML 要素</param>
    /// <returns>
    /// 変換された結果の値。無効な場合は defaultvalue。
    /// </returns>
    toFormDefaultOptions.appliers["data-app-format"] = function (value, element) {
        if (/\/Date\((\d+)\)\//gi.test(value)) {
            value = parseJsonDate(value);
            var format = element.attr("data-app-format");

            if (!App.isUndefOrNull(format) && format === "date") {
                value = App.data.getDateString(value, true);
            } else {
                value = App.data.getDateTimeString(value, true);
            }

            if (element.is(":input")) {
                element.val(value);
            } else {
                if (!App.isUndefOrNull(value)) {
                    element.text(value);
                } else {
                    element.text("");
                }
            }
            
            return true;
        }

        return false;
    };

    // カンマ区切りのフォーマットを適用する
    toFormDefaultOptions.appliers["data-app-number"] = function (value, element) {
        var str = value;
        var num = new String(str).replace(/,/g, "");
        while (num != (num = num.replace(/^(-?\d+)(\d{3})/, "$1,$2")));

        if (element.is(":input")) {
            if (!App.isUndefOrNull(value)) {
                element.val(num);
            } else {
                element.val("");
            }
        } else {
            if (!App.isUndefOrNull(value)) {
                element.text(num);
            } else {
                element.text("");
            }
        }
        return true;
    };

    if ($.datepicker) {
        /// <summary>
        /// jQuery UI Datepicker が適用されたHTML フォーム要素の値からオブジェクトへの変換を行う際の変換を定義します。
        /// </summary>
        /// <param name="element">HTML 要素</param>
        /// <param name="defaultvalue">規定値</param>
        /// <returns>
        /// 変換された結果の値。無効な場合は defaultvalue。
        /// </returns>
        toJSONDefaultOptions.converters[$.datepicker.markerClassName] = function (element, defaultValue) {
            var date = element.datepicker("getDate");
            return typeof date === "undefined" ? null : date;
        };

        /// <summary>
        /// オブジェクトから jQuery UI Datepicker が適用されたHTML フォーム要素の値変換を行う際の変換を定義します。
        /// </summary>
        /// <param name="value">オブジェクトのプロパティ値</param>
        /// <param name="element">HTML 要素</param>
        /// <returns>
        /// 変換された結果の値。無効な場合は defaultvalue。
        /// </returns>
        toFormDefaultOptions.appliers[$.datepicker.markerClassName] = function (value, element) {
            if (/\/Date\((\d+)\)\//gi.test(value)) {
                element.datepicker("setDate", parseJsonDate(value));
                return true;
            } else if (App.isDate(value)){
                element.datepicker("setDate", value);
                return true;
            }
            return false;
        };
    }

    /// <summary>
    /// JSON フォーマットの文字列を Date オブジェクトに変換します。
    /// </summary>
    /// <param name="jsonDate">JSON フォーマットの文字列</param>
    /// <returns>文字列から変換された Date オブジェクト</returns>
    var parseJsonDate = function (jsonDate) {
        if (jsonDate == null) {
            return null;
        }
        return eval(jsonDate.replace(/\/Date\((\d+)\)\//gi, "new Date($1)"));
    };


    /// <summary>
    /// toJSON ファンクションで利用する converter を定義します。
    /// </summary>
    App.define("App.data.converters", {

    });

    /// <summary>
    /// toForm ファンクションで利用する Applier を定義します。
    /// </summary>
    App.define("App.data.appliers", {

    });

})(this, jQuery);

// data
(function (global, $, undef) {

    App.define("App.data",{

        /// <summary>数値の0埋めを行います。</summary>
        /// <param name="num">0埋め前の数値</param>
        toDoubleDigits: function(num){
            num += "";
            if (num.length === 1) {
                num = "0" + num;
            }
            return num;
        },

        /// <summary>数値の3桁区切りを行います。</summary>
        /// <param name="num">桁区切り前の数値</param>
        toSeparatedDigits: function(num){
			var result = new String(num).replace(/,/g, "");
			while(result != (result = result.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
			return result;
        },

        /// <summary>日付時刻文字列を取得します。</summary>
        /// <param name="date">日付</param>
        /// <param name="isLocal">ローカル日付かどうか</param>
        getDateTimeString: function (date, isLocal) {
            var utc = isLocal ? "" : "UTC";
            if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh') {
                var result = date["get" + utc + "FullYear"]() + "/" +
                        App.data.toDoubleDigits(date["get" + utc + "Month"]() + 1) + "/" +
                        App.data.toDoubleDigits(date["get" + utc + "Date"]()) + " " +
                        App.data.toDoubleDigits(date["get" + utc + "Hours"]()) + ":" +
                        App.data.toDoubleDigits(date["get" + utc + "Minutes"]()) + ":" +
                        App.data.toDoubleDigits(date["get" + utc + "Seconds"]());
            } else if (App.ui.page.langCountry == 'en-US') {
                var result = App.data.toDoubleDigits(date["get" + utc + "Month"]() + 1) + "/" +
                        App.data.toDoubleDigits(date["get" + utc + "Date"]()) + "/" +
                        date["get" + utc + "FullYear"]() + " " +
                        App.data.toDoubleDigits(date["get" + utc + "Hours"]()) + ":" +
                        App.data.toDoubleDigits(date["get" + utc + "Minutes"]()) + ":" +
                        App.data.toDoubleDigits(date["get" + utc + "Seconds"]());
            } else {
                var result = App.data.toDoubleDigits(date["get" + utc + "Date"]()) + "/" +
                        App.data.toDoubleDigits(date["get" + utc + "Month"]() + 1) + "/" +
                        date["get" + utc + "FullYear"]() + " " +
                        App.data.toDoubleDigits(date["get" + utc + "Hours"]()) + ":" +
                        App.data.toDoubleDigits(date["get" + utc + "Minutes"]()) + ":" +
                        App.data.toDoubleDigits(date["get" + utc + "Seconds"]());
            }
            return result;
        },

        /// <summary>日付文字列を取得します。</summary>
        /// <param name="date">日付</param>
        /// <param name="isLocal">ローカル日付かどうか</param>
        getDateString: function (date, isLocal) {
            var utc = isLocal ? "" : "UTC";
            if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh' ){
                var result = date["get" + utc + "FullYear"]() + "/" +
                        App.data.toDoubleDigits(date["get" + utc + "Month"]() + 1) + "/" +
                        App.data.toDoubleDigits(date["get" + utc + "Date"]());
            } else if (App.ui.page.langCountry == 'en-US') {
                var result = App.data.toDoubleDigits(date["get" + utc + "Month"]() + 1) + "/" +
                    App.data.toDoubleDigits(date["get" + utc + "Date"]()) + "/" +
                    date["get" + utc + "FullYear"]();
            } else {
                var result = App.data.toDoubleDigits(date["get" + utc + "Date"]()) + "/" +
                    App.data.toDoubleDigits(date["get" + utc + "Month"]() + 1) + "/" +
                    date["get" + utc + "FullYear"]();
            }
            return result;
        },

        /// <summary>日付文字列を取得します。</summary>
        /// <param name="date">日付</param>
        /// <param name="date">ローカル日付かどうか</param>
        getDateStringNenTsukiHi: function (date, isLocal) {
            var utc = isLocal ? "" : "UTC",
                result = date["get" + utc + "FullYear"]() + "年" +
                    App.data.toDoubleDigits(date["get" + utc + "Month"]() + 1) + "月" +
                    App.data.toDoubleDigits(date["get" + utc + "Date"]()) + "日";
            return result;
        },

        /// <summary>クエリのフィルタ用日付文字列を取得します。</summary>
        /// <param name="date">日付</param>
        /// <param name="date">ローカル日付かどうか</param>
        getDateTimeStringForQuery: function (date, isLocal) {
            
            var utc = isLocal ? "" : "UTC",
                result = date["get" + utc + "FullYear"]() + "-" +
                    App.data.toDoubleDigits(date["get" + utc + "Month"]() + 1) + "-" +
                    App.data.toDoubleDigits(date["get" + utc + "Date"]()) + "T" +
                    App.data.toDoubleDigits(date["get" + utc + "Hours"]()) + ":" +
                    App.data.toDoubleDigits(date["get" + utc + "Minutes"]()) + ":" +
                    App.data.toDoubleDigits(date["get" + utc + "Seconds"]());
            return result;
        },

        /// <summary>クエリのフィルタ用日付文字列を取得します。(10:00:00固定)</summary>
        /// <param name="date">日付</param>
        /// <param name="date">ローカル日付かどうか</param>
        getDateTimeStringForQueryNoUtc: function (date) {
            
            var result = date["getFullYear"]() + "-" +
                    App.data.toDoubleDigits(date["getMonth"]() + 1) + "-" +
                    App.data.toDoubleDigits(date["getDate"]()) + "T" +
                    "10:00:00";
            return result;
        },

        /// <summary>クエリのフィルタ用日付文字列を取得します。</summary>
        /// <param name="date">日付</param>
        /// <param name="date">ローカル日付かどうか</param>
        getDateTimeStringForQueryNoTime: function (date, isLocal) {
            
            var utc = isLocal ? "" : "UTC",
                result = date["get" + utc + "FullYear"]() + "-" +
                    App.data.toDoubleDigits(date["get" + utc + "Month"]() + 1) + "-" +
                    App.data.toDoubleDigits(date["get" + utc + "Date"]()) + "T00:00:00";
            return result;
        },

        /// <summary>クエリのフィルタ用日付文字列（FROM)を取得します。</summary>
        /// <param name="date">日付</param>
        getFromDateStringForQuery: function (date) {
             var result = date["getFullYear"]() + "/" +
                    App.data.toDoubleDigits(date["getMonth"]() + 1) + "/" +
                    App.data.toDoubleDigits(date["getDate"]()) + " " +
                    "00:00:00";
 
            return App.data.getDateTimeStringForQuery(new Date(result), false);
        },
 
        /// <summary>クエリのフィルタ用日付文字列（To)を取得します。</summary>
        /// <param name="date">日付</param>
        getToDateStringForQuery: function (date) {
            var result = date["getFullYear"]() + "/" +
                    App.data.toDoubleDigits(date["getMonth"]() + 1) + "/" +
                    App.data.toDoubleDigits(date["getDate"]()) + " " +
                    "23:59:59";
 
            return App.data.getDateTimeStringForQuery(new Date(result), false);
        },
 
        getDate: function (value) {
            var result;
            if (typeof value === "string" && value.match(/\/Date\((-?\d*)\)\//g)) {
                result = (new Function("return " + value.replace(/\/Date\((-?\d*)\)\//g, "new Date($1)")))();
            }
            return result;
        },

        /// <summary>日付入力項目の5桁目と8桁目に自動でスラッシュを追加します。</summary>
        /// <param name="e">イベントオブジェクト</param>
        addSlashForDateString: function (e) {
            if (e) {
                if (e.keyCode != "8") {
                    if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh'){
                        if (e.target.value.length == 4) e.target.value = e.target.value + "/";
                        if (e.target.value.length == 7) e.target.value = e.target.value + "/";
                    } else {
                        if (e.target.value.length == 2) e.target.value = e.target.value + "/";
                        if (e.target.value.length == 5) e.target.value = e.target.value + "/";
                    }
                }
            }
        },
        /// <summary>日付入力項目（月まで）の5桁目に自動でスラッシュを追加します。</summary>
        /// <param name="e">イベントオブジェクト</param>
        addSlashForMonthString: function (e) {
            if (e) {
                if (e.keyCode != "8") {
                    if (App.ui.page.lang == 'ja' || App.ui.page.lang == 'zh'){
                        if (e.target.value.length == 4) e.target.value = e.target.value + "/";
                    } else {
                        if (e.target.value.length == 2) e.target.value = e.target.value + "/";
                    }
                }
            }
        },

        /// <summary>WCF Data ServicesのODataシステムクエリオプションを生成します。</summary>
        /// <param name="date">クエリオブジェクト</param>
        toODataFormat: function (query) {
            var parameters = [],
                p;

            for (p in query) {
                if (!query.hasOwnProperty(p) || p === "url") {
                    continue;
                }
                if (!App.isUndefOrNull(query[p]) && query[p].toString().length > 0) {
                    parameters.push("$" + p + "=" + query[p]);
                }
            }

            return query.url + "?" + parameters.join("&");
        },

        /// <summary>webAPI Servicesのクエリオプションを生成します。</summary>
        /// <param name="date">クエリオブジェクト</param>
        toWebAPIFormat: function (query) {
            var parameters = [],
                p;

            for (p in query) {
                if (!query.hasOwnProperty(p) || p === "url") {
                    continue;
                }
                if (!App.isUndefOrNull(query[p]) && query[p].toString().length > 0) {
                    parameters.push(p + "=" + query[p]);
                }
            }

            return query.url + "?" + parameters.join("&");
        },

	    //// 計算用関数 -- Start

	    /// <summary>数値の長さを取得します。</summary>
        /// <param name="value">数値</param>
	    getDecimalLength: function (value) {
	        var list = (value + '').split('.')
                , isDeci = false;
	        isDeci = !App.isUndef(list[1]) && list[1].length > 0;
	        return isDeci ? list[1].length : 0;
	    },

	    /// <summary>乗算処理をします。</summary>
        /// <param name="value1">被乗数</param>
        /// <param name="value2">乗数</param>
	    calculatorMultiply: function (value1, value2) {
	        var intValue1 = +(value1 + '').replace('.', ''),
                intValue2 = +(value2 + '').replace('.', ''),
                decimalLength = App.data.getDecimalLength(value1) + App.data.getDecimalLength(value2),
                result;

	        result = (intValue1 * intValue2) / Math.pow(10, decimalLength);
	        return result;
	    },

	    /// <summary>除算処理をします。</summary>
        /// <param name="value1">被除数</param>
        /// <param name="value2">除数</param>
	    calculatorDivide: function (value1, value2) {
	        var intValue2 = +(value2 + '').replace('.', '');
	        var valAry = value2.toString().split(".");
	        var deciLen = valAry.length == 2 ? valAry[1].length : 0;
	        var numerator = Math.pow(10, deciLen);
	        var result = App.data.calculatorMultiply(value1, (numerator / intValue2));

	        return result;
	    },

	    /// <summary>減算処理をします。</summary>
        /// <param name="value1">被減数</param>
        /// <param name="value2">減数</param>
	    calculatorSubtract: function (value1, value2) {
	        var max = Math.max(App.data.getDecimalLength(value1), App.data.getDecimalLength(value2)),
                k = Math.pow(10, max);
	        return (App.data.calculatorMultiply(value1, k) - App.data.calculatorMultiply(value2, k)) / k;
	    },

	    /// <summary>Decimal的(文字列)操作の関数化(decimaloperater.js)
        /// 　使用例：val = App.data.trimFixed(4.9999 * 100)</summary>
        /// <param name="a">値</param>
        trimFixed: function (a) {
	        var x = "" + a;
	        var m = 0;
	        var e = x.length;

	        for (var i = 0; i < x.length; i++) {
		        var c = x.substring(i, i+1);
		        if (c >= "0" && c <= "9") {
			        if (m == 0 && c == "0") {
			        }
			        else {
				        m++;
			        }
		        }
		        else if (c == " " || c == "+" || c == "-" || c == ".") {
		        }
		        else if(c == "E" || c == "e") {
			        e = i;
			        break;
		        }
		        else {
			        return a;
		        }
	        }

	        var b = 1.0 / 3.0;
	        var y = "" + b;
	        var q = y.indexOf(".");
	        var n;

	        if (q >= 0) {
		        n = y.length - (q + 1);
	        }
	        else{
		        return a;
	        }

	        if (m < n) {
		        return a;
	        }
	        var p = x.indexOf(".");
	        if (p == -1) {
		        return a;
	        }
	        var w = " ";
	        for (var i = e - (m - n) - 1; i >= p + 1; i--) {
		        var c = x.substring(i, i+1);
		        if (i == e - (m - n) - 1) {
			        continue;
		        }
		        if (i == e - (m - n) - 2) {
			        if (c == "0" || c == "9") {
				        w = c;
				        continue;
			        }
			        else {
				        return a;
			        }
		        }
		        if (c != w) {
			        if (w == "0") {
				        var z = (x.substring(0, i+1) + x.substring(e, x.length)) - 0;
				        return z;
			        }
			        else if (w == "9") {
				        var z = (x.substring(0, i) + ("" + ((c - 0) + 1)) + x.substring(e, x.length)) - 0;
				        return z;
			        }
			        else {
				        return a;
			        }
		        }
	        }

	        if (w == "0") {
		        var z = (x.substring(0, p) + x.substring(e, x.length)) - 0;
		        return z;
	        }
	        else if(w == "9") {
		        var z = x.substring(0, p) - 0;
		        var f;
		        if (a > 0) {
			        f = 1;
		        }
		        else if (a < 0) {
			        f = -1;
		        }
		        else {
			        return a;
		        }
		        var r = (("" + (z + f)) + x.substring(e, x.length)) - 0;
		        return r;
	        }
	        else {
		        return a;
	        }
        }

	    //// 計算用関数 -- End
    });

})(this, jQuery);

// sync
(function (global, $, undef) {

    App.define("App.sync", {

        // QRコードの取得後、実行する処理を登録する
        // handler: QRコード取得後に実行する処理（引数のない関数）
        // delay: handlerの実行インターバル(ms)
        // doc: QRコード表示対象ドキュメント
        // Chromeの場合、QRコードが表示されないことがあるため、
        // QRコードの読み込み完了まで、delay(ms)毎にhandlerの呼び出しをトライする
        // QRコード読込済みとなった後、handlerの呼び出しを実行する
        loadQRHandler: function (handler, delay, doc) {

            var images = $(doc)[0].images;
            var imagCount = images.length;
            var loadCount = 0;
            $(images).on('load', function () {
                // QRコードのロードが完了したらインクリメントする
                loadCount++;

                console.log("images loaded. imagCount=" + imagCount + ", loadCount=" + loadCount);
            });

            // Chromeの場合、QRコードの取得がされる前に画面表示されてしまうため
            // QRコードの取得が終わるまで印刷ダイアログの表示を待機する
            var intervalID = setInterval(function () {
                if (loadCount === imagCount) {
                    // 1回だけ実行したいので、実行が確定したら繰り返し実行取り消す
                    clearInterval(intervalID);
                    // ハンドラの処理を実行する
                    if ($.isFunction(handler)) {
                        handler();
                    }
                }
            }, delay);
        },

    });

})(this, jQuery);
