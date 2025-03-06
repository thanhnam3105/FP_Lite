
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "仕込日報" },

        // 【最小値】 日付
        minDate: { text: "2000/01/01" },
        // 【最大値】 日付
        maxDate: { text: "3000/12/31" },
        // 【値】 1日
        oneDay: { text: 86400000 },
        timeNewFormat: { text: "H:i" },
        dt_diff: { text: 31 },
        month_diff: { text: 6 },

        shokuba: { text: "職場" },
        line: { text: "ライン" },
        flg_jisseki: { text: "確定" },
        cd_shikakari_hin: { text: "コード" },
        nm_haigo: { text: "仕掛品名" },
        cd_line: { text: "ラインコード" },
        nm_line: { text: "ライン名" },
        nm_tani: { text: "使用単位" },
        wt_shikomi_keikaku: { text: "仕込量(予定)" },
        wt_shikomi_jisseki: { text: "仕込量" },
        ritsu_jisseki: { text: "倍率" },
        ritsu_jisseki_hasu: { text: "倍率(端数)" },        
        su_batch_jisseki: { text: "Ｂ数" },
        su_batch_jisseki_hasu: { text: "Ｂ数(端数)" },
        wt_zaiko_jisseki: { text: "残使用量" },
        wt_shikomi_zan: { text: "当日残" },
        no_lot_shikakari: { text: "ロット番号" },
        dt_seizo: { text: "製造日" },
        dt_seizo_start: { text: "製造日（開始）" },
        dt_seizo_end: { text: "製造日（終了）" },
        between: { text: "～" },
        wt_haigo_gokei: { text: "合計配合重量" },
        wt_hitsuyo: { text: "必要量" },
        cd_shokuba: { text: "" },
        shikomi: { text: "仕込" },
        seizoJissekiSentaku: { text: "製造実績選択" },
        densoJotai: { text: "伝送状態" },
        flg_toroku: { text: "登録チェック" },
        kbn_toroku_jotai: { text: "登録状況" },
        msg_kakuteiData: { text: "確定データ" },
        denso_jokyo: { text: "伝送状態" },
        mi_sakusei: { text: "未作成" },
        mi_denso: { text: "未伝送" },
        denso_machi: { text: "伝送待" },
        denso_zumi: { text: "伝送済" },
        toroku_jokyo: { text: "登録状況" },
        mi_toroku: { text: "未登録" },
        ichibu_mi_toroku: { text: "一部未登録" },
        toroku_sumi: { text: "登録済" },
        lotToroku: { text: "ロット登録" },
        lotTorokuZenbu: { text: "全チェック/解除" },

        chk_search_non: { text: 0 },
        chk_search_on: { text: 1 },

        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        deleteConfirm: { text: MS0752 },
        // 画面の仕様に応じて以下の列幅を変更してください。
        flg_jisseki_width: { number: 60 },        
        densoJotai_width: { number: 80 },
        wt_shikomi_keikaku_width: { number: 100 },
        flg_toroku_width: { number: 60 },
        nm_toroku_jotai: { number: 80 },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        dateDiffError: { text: MS0686 }        
    });

    App.ui.pagedata.validation("ja", {
        // 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 検索条件/製造日（開始）
        con_dt_seizo_from: {
            rules: {
                required: "製造日（開始）",
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        // 検索条件/製造日（終了）
        con_dt_seizo_to: {
            rules: {
                required: "製造日（終了）",
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        // 仕掛品
        cd_shikakari_hin: {
            rules: {
                required: "コード",
                maxbytelength: 14,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "コード"
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0005,
                custom: MS0049
            }
        },
        // ラインコード
        cd_line: {
            rules: {
                required: "ラインコード",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "コード"
            },
            messages: {
                required: MS0042,
                alphanum: MS0005,
                custom: MS0049
            }
        },
        // 倍率
        ritsu_jisseki: {
            rules: {
                required: "倍率",
                //pointlength: [6, 6, false],
                pointlength: [6, 2, false],
                //range: [0, 999999.999999],
                range: [0, 999999.99],
                custom: true
            },
            params: {
                //custom: ["仕込量、当日残", 0, 999999.999999]
                custom: ["仕込量", 0, 999999.999]
            },
            messages: {
                required: MS0042,
                pointlength: MS0440,
                range: MS0450,
                custom: MS0666
            }
        },
        // 倍率（端数)
        ritsu_jisseki_hasu: {
            rules: {
                //pointlength: [6, 6, false],
                pointlength: [6, 2, false],
                //range: [0, 999999.999999],
                range: [0, 999999.99],
                custom: true
            },
            params: {
                //custom: ["仕込量、当日残", 0, 999999.999999]
                custom: ["仕込量", 0, 999999.999]
            },
            messages: {
                pointlength: MS0440,
                range: MS0450,
                custom: MS0666
            }
        },
        // Ｂ数
        su_batch_jisseki: {
            rules: {
                required: "Ｂ数",
                //pointlength: [6, 6, false],
                digits: [6],
                //range: [0, 999999.999999],
                range: [0, 999999],
                custom: true
            },
            params: {
                //custom: ["仕込量、当日残", 0, 999999.999999]
                custom: ["仕込量", 0, 999999.999]
            },
            messages: {
                required: MS0042,
                //pointlength: MS0440,
                digits: MS0576,
                range: MS0450,
                custom: MS0666
            }
        },
        // Ｂ数(端数)
        su_batch_jisseki_hasu: {
            rules: {
                //pointlength: [6, 6, false],
                digits: [6],
                //range: [0, 999999.999999],
                range: [0, 999999],
                custom: true
            },
            params: {
                //custom: ["仕込量、当日残", 0, 999999.999999]
                custom: ["仕込量", 0, 999999.999]
            },
            messages: {
                //pointlength: MS0440,
                digits: MS0576,
                range: MS0450,
                custom: MS0666
            }
        },
        // 残使用量
        wt_zaiko_jisseki: {
            rules: {
                /*　画面上に残使用量の項目が無いため、コメントアウト
                //pointlength: [6, 6, false],
                pointlength: [6, 3, false],
                //range: [0, 999999.999999],
                range: [0, 999999.999],
                custom: true
                */
            },
            params: {
                //custom: ["仕込量、当日残", 0, 999999.999999]
                custom: ["仕込量", 0, 999999.999]
            },
            messages: {
                pointlength: MS0440,
                range: MS0450,
                custom: MS0666
            }
        }
    });

    // 第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // T画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        add: {
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        check: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        hinmei: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        line: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        lotTorokuZenbu: {
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });
    //// ページデータ -- End
})();
