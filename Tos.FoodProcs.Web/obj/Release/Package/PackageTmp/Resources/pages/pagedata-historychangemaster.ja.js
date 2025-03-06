(function () {
    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "変更履歴確認" },

        // 検索条件
        dt_from: { text: "日付（開始）" },
        dt_to: { text: "日付（終了）" },
        between: { text: "　～　" },
        DataPartition: { text: "データ区分" },
        ProcessingDivision: { text: "処理区分" },
        dt_update_from: { text: "更新日（開始）" },
        dt_update_to: { text: "更新日（終了）" },
        name: { text: "担当者" },
        hinCode: { text: "品コード" },

        // グリッド項目
        kbn_data: { text: "データ区分" },
        kbn_shori: { text: "処理区分" },
        dt_hizuke: { text: "日付" },
        cd_hinmei: { text: "品名コード" },
        nm_seihin: { text: "品名" },
        su_henko: { text: "変更後ケース数" },
        su_henko_hasu: { text: "変更後端数" },
        tr_lot: { text: "ロットNO" },
        dt_henko: { text: "更新日・時間" },
        cd_henko: { text: "担当ID" },
        nm_henko: { text: "担当者" },
        biko: { text: "備考" },

        nm_riyu: { text: "調整理由" },
        genka_busho: { text: "原価発生部署" },

        // その他：文言
        startDate: { text: "開始日" },
        endDate: { text: "終了日" },

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

    App.ui.pagedata.validation("ja", {
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
                greaterdate: MS0247,
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
        cd_hinmei: {
            rules: {
                maxbytelength: 14,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "品コード"
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0037
            }
        },
        cd_nm_tanto: {
            rules: {
                maxlength: 50
            },
            params: {
                custom: "担当者"
            },
            messages: {
                maxlength: MS0012
            }
        }
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("ja", {
        search: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

})();
