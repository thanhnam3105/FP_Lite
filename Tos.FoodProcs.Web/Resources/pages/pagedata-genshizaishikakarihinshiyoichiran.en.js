(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Material And Semi-Finished Product Use List" },
        // 検索条件
        kbn_hin: { text: "Item type" },
        bunrui: { text: "Group" },
        name: { text: "Name" },
        // グリッド項目
        kubun: { text: "Type" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Name" },
        cd_shikakari: { text: "Semi-finished<br>product code" },
        nm_shikakari: { text: "Semi-finished<br>product name" },
        wt_haigo: { text: "Formula<br>weight" },
        su_shiyo: { text: "Usage<br>quantity" },
        no_han: { text: "Version" },
        cd_seihin: { text: "Product code" },
        nm_seihin: { text: "Product name" },
        dt_saishu_shikomi_yotei: { text: "Date of the scheduled<br>last preparation" },   // エキサイト翻訳：The date of the scheduled last preparation
        dt_saishu_shikomi: { text: "Last preparation<br>day" },   // The last preparation day
        dt_saishu_seizo_yotei: { text: "Date of the scheduled<br>last manufacture" },     // The date of the scheduled last manufacture 
        dt_saishu_seizo: { text: "Last date<br>manufactured" },     // The last date manufactured 
        mishiyo: { text: "Unused" },
        shiyo: { text: "Used" },
        dt_from: { text: "Valid date" },
        // メッセージ
        //noRecords: { text: MS0442 },
        // 幅調整
        nm_kbn_hin_width: { number: 70 },
        last_date_width: { number: 150 },
        each_lang_width: { number: 90 }
        // ここまで

    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        kbn_hin: {
            rules: {
                required: "Item type"
            },
            messages: {
                required: MS0042
            }
        },
        dt_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(3000, 13 - 1, 31)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        }
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("en", {
        search: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        excel: {
            Warehouse: { visible: false }
        }
        //add: {
        //    Viewer: { visible: false }
        //}
    });

})();