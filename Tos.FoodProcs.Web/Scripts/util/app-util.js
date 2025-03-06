/// アプリケーションで使用する業務用の共通処理を記述します.
var app_util = function(){};

app_util.prototype = {

    /// <summary>
    ///     デフォルト表示する原価発生部署データのオブジェクトを返却するメソッド
    /// </summary>
    /// <param="genkaObjectList">原価発生部署データのオブジェクトリスト</param>
    /// <return>デフォルト表示する原価発生部署データのオブジェクト</return>
    getDefaultGenkaBusho: function (genkaObjectList) {

        var defaultCodeNum = 0;
        var cdGenkaCenter = pageLangText.genkaHaseiBushoDefaultCode.text;

        // 画面アーキテクチャ共通のデータロード
        App.deferred.parallel({
            // 工場マスタ
            kojoMaster: App.ajax.webgetSync("../Services/FoodProcsService.svc/ma_kojo?$filter=cd_kaisha eq '" + App.ui.page.user.KaishaCode + "' and cd_kojo eq '" + App.ui.page.user.BranchCode + "'")
        }).done(function (result) {

            // サービス呼び出し成功
            kojoMaster = result.successes.kojoMaster.d;

            // 工場マスタから取得した原価センターコードを設定する
            if (kojoMaster.length > 0 && !(kojoMaster[0].cd_genka_center == null || kojoMaster[0].cd_genka_center == undefined || kojoMaster[0].cd_genka_center == "")) {
                cdGenkaCenter = kojoMaster[0].cd_genka_center;
            }
        // サービス呼び出し失敗
        }).fail(function (result) {

            var length = result.key.fails.length,
                messages = [];

            for (var i = 0; i < length; i++) {
                var keyName = result.key.fails[i];
                var value = result.fails[keyName];
                messages.push(keyName + " " + value.message);
            }
            App.ui.page.notifyAlert.message(messages).show();
        }).always(function () {
        });

        // 工場マスタから取得した原価センタコードまたはコード21000のオブジェクトを原価発生部署の初期値とする
        for (var i = 0; i < genkaObjectList.length; i++) {
            //if (genkaObjectList[i].cd_genka_center == pageLangText.genkaHaseiBushoDefaultCode.text) {
            if (genkaObjectList[i].cd_genka_center == cdGenkaCenter) {
                defaultCodeNum = i;
                break;
            }
        }

        return genkaObjectList[defaultCodeNum];
    },

    /// <summary>
    ///     jqGrid内のドロップダウンリスト用の文字列の生成を行います。
    /// </summary>
    /// <param name="grid">対象のグリッド</param>
    /// <param name="source">ドロップダウンリストのデータソース</param>
    /// <param name="dropdownCd">ドロップダウンリストのコードの名前</param>
    /// <param name="dispStr">ドロップダウンリストの表示名の名前</param>
    /// <param name="isAddBlank">trueだと先頭に空白を追加する</param>
    /// <return>jqGrid用ドロップダウンリスト文字列</return>
    makeJQGridDropDownStr: function (grid, source, dispStr, dropdownCd, isAddBlank) {
        var result;

        // ドロップダウン用のデータリストがない場合は空のボックスを返却する
        if (source == null) {
            result = ":";
            return result;
        }

        if (isAddBlank) {
            // 既に先頭行に空白の行がある場合は追加しない
            if ((source.length > 0) && (source[0][dropdownCd] !== '')) {
                /*
                var addObj = new Object();
                addObj[dropdownCd] = '';
                addObj[dispStr] = '';

                source.unshift(addObj);
                */
                result = ":;";
            }
        }
        // return grid.prepareDropdown(source, dispStr, dropdownCd);

        for (var i = 0; i < source.length; i++) {
            result += source[i][dropdownCd];
            result += ':';
            result += source[i][dispStr];
            result += ';';
        }
        // 末尾の';'を削除
        result = result.substr(0, result.length - 1);
        return result;
    },

    /// <summary>
    ///     文字列で要素指定したjqGridドロップダウンリスト列のformatterに指定してください
    /// </summary>
    /// <param name="celldata">セルデータ</param>
    /// <param name="options">オプション</param>
    /// <param name="rowobject">行オブジェクト</param>
    /// <return>SPANタグで囲ったセルデータ</return>
    getFormatValueJQGridDropDownStr: function (celldata, options, rowobject) {
        var result;
        var optionStr = options.colModel.editoptions.value();
        var optObject = optionStr.split(';');
        var showdata = "";
        for (var key in optObject) {
            var map = optObject[key].split(":");
            var celldataStr = (celldata == null) ? "" : String(celldata);
            
            //if (map[0] == celldata) {
            if (map[0] === celldataStr) {
                showdata = map[1];
                break;
            }
        }

        if (celldata == null || celldata === "") {
            // コンボボックスの表示項目がnullの時は、コードに空文字を設定する
            result = $(document.createElement('span')).attr('original-value', '').text(showdata)[0].outerHTML;
        } else {
            // それ以外の時は、コードにセルデータを設定する
            result = $(document.createElement('span')).attr('original-value', celldata).text(showdata)[0].outerHTML;
        }
        return result;
    },

    /// <summary>
    /// Cookieを取得
    /// </summary>
    /// <param name="name">Cookie名称</param>
    /// <return>Cookieの値</return>
    getCookieValue: function (name) {
        var result = '',
            key = name + '=',
            _cookie = document.cookie,
            _s = _cookie.indexOf(key),
            _e = _cookie.indexOf(';', _s);
        _e = _e === -1 ? _cookie.length : _e;
        result = decodeURIComponent(_cookie.substring(_s, _e)).replace(key, '');
        return result;
    },
    /// <summary>
    /// Cookieの削除
    /// </summary>
    /// <param name="name">Cookie名称</param>
    deleteCookie: function (name) {
        document.cookie = name + pageLangText.delCookie.text;
    }

};