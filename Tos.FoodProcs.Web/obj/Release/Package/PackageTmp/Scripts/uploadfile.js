; (function ($, undef) {


    var toAbsolutePath = function(rel) {
        if (/^https?:\/\//.test(rel)) {
            return rel;
        } else {
            var current = location.pathname,
                i, l, splited = [];
            current = current.substr(0, current.lastIndexOf("/"));
            current = current.split("/");
            
            for(i = 0, l = current.length; i < l; i++){
                if(current[i] !== ""){
                    splited.push(current[i]);
                }
            }
            rel = rel.split("/");
            for (i = 0, l = rel.length; i < l; i++) {
                if (rel[i] === "..") {
                    splited.pop();
                } else if (rel[i] !== ".") {
                    splited.push(rel[i]);
                }
            }
            return location.protocol + "//" + location.host + "/" + splited.join("/");
        }
    }

    /// <summary>
    /// 引数で指定されたオプションを使用し、ファイルのアップロードを行います。
    /// </summary>
    $.fn.uploadfile = function (options) {
        var self = this,
            inputs,
            key = (new Date()).getTime().toString(),
            iframeName = 'file_upload' + key,
            iframe = $('<iframe name="' + iframeName + '" style="width: 0; height: 0; position:absolute;top:-9999px" />').appendTo('body'),
            form = '<form target="' + iframeName + '" method="post" enctype="multipart/form-data" accept-charset="UTF-8" />',
            deferr = $.Deferred(),
            targetOrigin;

        // options が指定されていない場合はデフォルト値を使用します。
        options = $.extend(true, {
            url: window.location.href,
            data: {
                __key: key
            }
        }, options);

        targetOrigin = (function () {
            var url = toAbsolutePath(options.url),
                a = $("<a href='" + url + "'></a>")[0],
                result = a.protocol + "//" + a.hostname;    
            if ((a.protocol === "http:" && a.port !== "80") || (a.protocol === "https:" && a.port !== "443")) {
                result += ":" + a.port;
            }
            return result;
        })();

        // IFrame 上の form タグに action 属性を追加し、ポストするパラメーターを追加します
        form = self.wrapAll(form).parent().attr('action', options.url);

        // オプションで指定された data を使って IFrame 上の form タグに hidden フィールドを追加します。
        inputs = createAndAppendInput(options.data, form);

        // IFrame 上で FORM タグのサブミットを実行します。
        form.submit(function () {
            var clienterror = {
                    result: false,
                    message: "アップロードの結果を取得できませんでした。"
                },
                handled = false,
                receiveMessage = function (ev) {
                    var result;
                    if(window.detachEvent){
                        window.detachEvent("onmessage", receiveMessage);
                    }else{
                        window.removeEventListener("message", receiveMessage);
                    }
                    
                    if (handled) {
                        return;
                    }
                    handled = true;
                    if (ev.origin !== targetOrigin || !ev.data) {
                        deferr.reject(clienterror);
                        return cleanup();
                    }
                    try {
                        result = (new Function("return " + ev.data.replace(/\r?\n/g, " ") + ";"))();
                    } catch (ex) {
                        clienterror.message += ex;
                        deferr.reject(clienterror);
                        return cleanup();
                    }

                    if (!result || !result.key || result.key !== key) {
                        clienterror.message += "結果がない、もしくはキーが一致しません。";
                        deferr.reject(clienterror);
                        return cleanup();
                    }
                    cleanup();
                    deferr[result.result ? "resolve" : "reject"](result);
                },
                cleanup = function () {
                    var i = 0,
                        inputLength = inputs.length;
                    //作成した input および form と iframe の削除
                    for (i = 0; i < inputLength; i++) {
                        inputs[i].remove();
                    }
                    self.unwrap();
                    iframe.remove();
                };
            if(window.attachEvent){
                window.attachEvent("onmessage", receiveMessage);
            }else{
                window.addEventListener("message", receiveMessage, false);
            }
            

            iframe.load(function () {
                var contents, uploadResult, message, data, success = true;
                if (handled) {
                    return;
                }
                handled = true;
                try {
                    contents = iframe.contents();
                } catch (e) {
                    clienterror.message += e;
                    deferr.reject(clienterror);
                    return cleanup();
                }

                uploadResult = contents.find(".result").text();
                message = contents.find(".message").text();
                data = contents.find(".data").text();

                cleanup();

                if (!uploadResult) {
                    success = false;
                } else {
                    success = uploadResult.toString().toUpperCase() === "TRUE";
                }
                if (data) {
                    data = JSON.parse(data);
                }
                if (success) {
                    deferr.resolve({
                        result: true,
                        message: message,
                        data: !!data ? data : undef
                    });
                } else {
                    deferr.reject({
                        result: false,
                        message: message,
                        data: !!data ? data : undef
                    });
                }
            });
        });

        setTimeout(function(){
            form.submit();
        }, 500);

        return deferr.promise();
    };

    /// <summary>
    /// オプションで指定された data から hidden フィールドのタグを生成します。
    /// </summary>
    var createAndAppendInput = function (data, form) {
        var inputs = [],
            input;
        for (var key in data) {
            if (data.hasOwnProperty(key)) {
                input = $("<input type='hidden' name='" + key + "' value='" + data[key] + "'>");
                form.append(input);
                inputs.push(input);
            }
        }
        return inputs;
    };

})(jQuery);
