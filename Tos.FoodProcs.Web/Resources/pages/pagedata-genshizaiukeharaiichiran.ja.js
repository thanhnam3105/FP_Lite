(function () {
    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原資材受払一覧" },

        // 検索条件
        dt_hiduke_search: { text: "日付" },
        between: { text: "　～　" },
        flg_mishiyobun: { text: "未使用分含む" },
        ari_nomi: { text: "計算在庫／実在庫ありのみ" },
        hinKubun: { text: "品区分" },
        hinBunrui: { text: "品分類" },
        hinCode: { text: "原資材コード" },
        hinName: { text: "原資材名" },
        flg_today_jisseki: { text: "当日は実績を表示" },
        ukeKubun: { text: "受払区分" },

        // グリッド項目
        cd_genshizai: { text: "原資材コード" },
        nm_genshizai: { text: "原資材名" },
        dt_hiduke: { text: "日付" },
        kbn_ukeharai: { text: "入出庫" },
        su_nyusyukko: { text: "入出庫数" },
        no_lot: { text: "ロットNo．" },
        cd_seihin: { text: "コード" },
        nm_seihin: { text: "品名" },
        nm_memo: { text: "メモ" },
        nm_shokuba: { text: "職場" },
        nm_line: { text: "ライン" },
        //受払区分
        nonyuYotei: { text: "納入予定" },
        nonyuJisseki: { text: "納入実績" },
        shiyoYotei: { text: "使用予定" },
        shiyoJisseki: { text: "使用実績" },
        chosei: { text: "調整数" },
        seizoYotei: { text: "製造予定" },
        seizoJisseki: { text: "製造実績" },
        // その他：文言
        startDate: { text: "開始日" },
        endDate: { text: "終了日" },
         // 開始日～終了日の最大期間日数
        maxPeriod: { text: "184" },
           
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
                required: "開始日付",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
                
            },

            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247 
            }
        },
        dt_hiduke_to: {
            rules: {
                required: "終了日付",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        kbn_hin: {
            rules: {
                required: "品区分"
            },
            messages: {
                required: MS0042
            }
        },
        cd_genshizai: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439
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
