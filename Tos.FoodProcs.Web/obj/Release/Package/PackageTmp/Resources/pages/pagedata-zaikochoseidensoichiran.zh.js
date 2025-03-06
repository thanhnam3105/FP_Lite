(function () {
    var lang = App.ui.pagedata.lang("zh", {
        _pageTitle: { text: "库存调整传送一览" },

        // ヘッダー項目
        to: { text: "～" },
        dateDensoSt: { text: "传送日(开始)" },
        dateDensoEn: { text: "传送日(结束)" },
        dateTenkiSt: { text: "过帐日(开始)" },
        dateTenkiEn: { text: "过帐日(结束)" },
        codeHinmei: { text: "品名编号" },
        chk_search_non: { text: 0 },
        chk_search_on: { text: 1 },

        //明細項目
        dt_denso: { text: "传送日期和时间" },
        kbn_denso_SAP: { text: "SAP传送区分" },
        dt_tenki: { text: "过帐日" },
        cd_soko: { text: "仓库编号" },
        nm_soko: { text: "仓库名" },
        cd_genka_center: { text: "原价中心编号" },
        nm_genka_center: { text: "原价中心名" },
        cd_riyu: { text: "理由编号" },
        nm_riyu: { text: "理由名" },
        cd_hinmei: { text: "品名编号" },
        nm_hinmei: { text: "品名" },
        su_chosei: { text: "调整数" },
        cd_tani: { text: "单位编号" },
        nm_tani: { text: "单位名" },
        dt_denpyo: { text: "传票日" },
        kbn_ido: { text: "移动区分" },

        //明細幅
        dt_denso_width: { number: 145 },
        kbn_denso_SAP_width: { number: 100 },
        dt_tenki_width: { number: 100 },
        cd_soko_width: { number: 100 },
        nm_soko_width: { number: 100 },
        cd_genka_center_width: { number: 120 },
        nm_genka_center_width: { number: 120 },
        cd_riyu_width: { number: 90 },
        nm_riyu_width: { number: 100 },
        cd_hinmei_width: { number: 100 },
        nm_hinmei_width: { number: 130 },
        su_chosei_width: { number: 100 },
        cd_tani_width: { number: 90 },
        nm_tani_width: { number: 80 },
        dt_denpyo_width: { number: 100 },
        kbn_ido_width: { number: 80 },

        //伝送区分名
        kbn_add: { text: "新建" },
        kbn_upd: { text: "更新" },
        kbn_del: { text: "删除" },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        requiredInput: { text: "查找条件中任意一个" },
        inputCheck: { text: MS0042 },
        overData: { text: MS0568 },


        // その他、定数定義、固定文言、隠し項目など
        each_lang_width: { text: "8em" },

        // TODO: 画面の仕様に応じて以下の列幅を変更してください。

        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // バリデーションルールとバリデーションメッセージ
        dt_denso_start: {
            rules: {
                required: "传送日(开始)",
                datestring: "传送日(开始)",
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages: {
                required: MS0042,
                datestring: MS0057,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        dt_denso_end: {
            rules: {
                required: "传送日(结束)",
                datestring: "传送日(结束)",
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages: {
                required: MS0042,
                datestring: MS0057,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        dt_tenki_start: {
            rules: {
                required: "过帐日(开始)",
                datestring: "过帐日(开始)",
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages: {
                required: MS0042,
                datestring: MS0057,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        dt_tenki_end: {
            rules: {
                required: "过帐日(结束)",
                datestring: "过帐日(结束)",
                greaterdate: new Date("3001/01/01"),
                lessdate: new Date("1969/12/31")
            },
            messages: {
                required: MS0042,
                datestring: MS0057,
                greaterdate: MS0247,
                lessdate: MS0247
            }
        },
        cd_hinmei: {
            rules: {
                alphanum: true,
                custom: true
            },
            params: {
                custom: "品名编号"
            },
            messages: {
                alphanum: MS0439,
                custom: MS0049
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("zh", {
        search: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

})();
