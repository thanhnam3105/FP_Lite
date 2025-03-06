(function () {
    var lang = App.ui.pagedata.lang("zh", {
        _pageTitle: { text: "变更记录确认" },

        // 検索条件
        dt_from: { text: "日期（开始）" },
        dt_to: { text: "日期（结束）" },
        between: { text: "　～　" },
        DataPartition: { text: "数据区分" },
        ProcessingDivision: { text: "処理区分" },
        dt_update_from: { text: "更新日（开始）" },
        dt_update_to: { text: "更新日（结束）" },
        name: { text: "担当者" },
        hinCode: { text: "品名编号" },

        // グリッド項目
        kbn_data: { text: "数据区分" },
        kbn_shori: { text: "処理区分" },
        dt_hizuke: { text: "日期" },
        cd_hinmei: { text: "品名编号" },
        nm_seihin: { text: "品名" },
        su_henko: { text: "変更后箱数" },
        su_henko_hasu: { text: "变更后零头数" },
        tr_lot: { text: "批号" },
        dt_henko: { text: "更新日" },
        cd_henko: { text: "担当者ID" },
        nm_henko: { text: "担当者" },
        biko: { text: "备注" },

        nm_riyu: { text: "调整理由" },
        genka_busho: { text: "原价发生部门" },

        // その他：文言
        startDate: { text: "开始日" },
        endDate: { text: "结束日" },

        // 開始日～終了日の最大期間日数
        maxPeriod: { text: "62" },

        // 幅調整
        nm_kbn_hin_width: { number: 70 },
        last_date_width: { number: 110 },
        each_lang_width: { number: 90 },
        kbn_ukeharai_width: { number: 70 },
        flg_mishiyobun_width: { number: 195 },
        ari_nomi_width: { number: 195 },
        flg_today_jisseki_width: { number: 195 }
        // ここまで

    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 検索条件
        dt_hiduke_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)

            },

            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_hiduke_to: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_update_from: {
            rules: {
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)

            },

            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_update_to: {
            rules: {
                //required: "更新日（结束）",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 3, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                //required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        cd_nm_tanto: {
            rules: {
                maxbytelength: 50
            },
            params: {
                custom: "担当者"
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        cd_hinmei: {
            rules: {
                maxbytelength: 14,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "品名编号"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0037
            }
        }
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("zh", {
        colchange: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Warehouse: { visible: true }
        }
    });

})();
