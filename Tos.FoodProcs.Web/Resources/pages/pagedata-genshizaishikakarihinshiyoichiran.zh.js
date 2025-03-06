(function () {
    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原材料・半成品使用一览" },

        // 検索条件
        //kbn_hin: { text: "品区分" },
        kbn_hin: { text: "商品区分" },
        bunrui: { text: "分类" },
        name: { text: "名称" },
        // グリッド項目
        kubun: { text: "区分" },
        cd_hinmei: { text: "编号" },
        nm_hinmei: { text: "名称" },
        cd_shikakari: { text: "半成品编号" },
        nm_shikakari: { text: "半成品名" },
        wt_haigo: { text: "配料重量" },
        su_shiyo: { text: "使用数" },
        no_han: { text: "版本" },
        cd_seihin: { text: "产品编号" },
        nm_seihin: { text: "产品名" },
        dt_saishu_shikomi_yotei: { text: "最后投入预定日" },
        dt_saishu_shikomi: { text: "最后投入日" },
        dt_saishu_seizo_yotei: { text: "最后生产预定日" },
        dt_saishu_seizo: { text: "最后生产日" },
        mishiyo: { text: "未使用" },    //Unused
        shiyo: { text: "使用" },
        dt_from: { text: "有效日期" },
        // メッセージ
        //noRecords: { text: MS0442 },
        // 幅調整
        nm_kbn_hin_width: { number: 70 },
        last_date_width: { number: 110 },
        each_lang_width: { number: 90 }
        // ここまで

    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        kbn_hin: {
            rules: {
                required: "品区分"
            },
            messages: {
                required: MS0042
            }
        },
        dt_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(3000, 12 - 1, 32)
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
    App.ui.pagedata.operation("zh", {
        search: {
            Warehouse: { visible: false }
        },
        colchange: {
            Warehouse: { visible: false }
        },
        excel: {
            Warehouse: { visible: false }
        }
    });

})();
