
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Daily Report Of Mixer" },

        // 【最小値】 日付
        minDate: { text: "2000/01/01" },
        // 【最大値】 日付
        maxDate: { text: "3000/12/31" },
        // 【値】 1日
        oneDay: { text: 86400000 },
        timeNewFormat: { text: "H:i" },
        dt_diff: { text: 31 },
        month_diff: { text: 6 },

        shokuba: { text: "Workplace" },
        line: { text: "Line" },
        flg_jisseki: { text: "Confirm" },
        cd_shikakari_hin: { text: "Code" },
        nm_haigo: { text: "Name" },
        cd_line: { text: "Line code" },
        nm_line: { text: "Line name" },
        nm_tani: { text: "Usage<br>unit" },
        wt_shikomi_keikaku: { text: "Produce quantity<br>(plan)" },
        wt_shikomi_jisseki: { text: "Produce quantity" },
        ritsu_jisseki: { text: "Magnification" },
        ritsu_jisseki_hasu: { text: "Magnification<br>(fraction)" },
        su_batch_jisseki: { text: "Batch quantity" },
        su_batch_jisseki_hasu: { text: "Batch quantity<br>(fraction)" },
        wt_zaiko_jisseki: { text: "Inventory of<br>usage quantity" },
        wt_shikomi_zan: { text: "Inventory of today" },
        no_lot_shikakari: { text: "lot No." },
        dt_seizo: { text: "Manufacture date" },
        dt_seizo_start: { text: "Manufacture date (start)" },
        dt_seizo_end: { text: "Manufacture date (end)" },
        between: { text: "～" },
        wt_haigo_gokei: { text: "Total formula<br>weight" },
        wt_hitsuyo: { text: "Required<br>quantity" },
        cd_shokuba: { text: "" },
        shikomi: { text: "Produce" },
        seizoJissekiSentaku: { text: "Manufacturing performance" },
        densoJotai: { text: "Status of allocated data" },
        flg_toroku: { text: "Register" },
        kbn_toroku_jotai: { text: "Register condition" },
        msg_kakuteiData: { text: "Deterministic data" },
        denso_jokyo: { text: "Status of allocated data" },
        mi_sakusei: { text: "Not created" },
        mi_denso: { text: "Not transmitted" },
        denso_machi: { text: "Pending" },
        denso_zumi: { text: "Transmitted" },
        toroku_jokyo: { text: "Register condition" },
        mi_toroku: { text: "Unregistered" },
        ichibu_mi_toroku: { text: "Pending" },
        toroku_sumi: { text: "Registered" },
        lotToroku: { text: "Register lot no" },
        lotTorokuZenbu: { text: "Check/ uncheck register" },

        chk_search_non: { text: 0 },
        chk_search_on: { text: 1 },

        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        deleteConfirm: { text: MS0752 },
        // 画面の仕様に応じて以下の列幅を変更してください。
        flg_jisseki_width: { number: 60 },        
        densoJotai_width: { number: 170 },
        wt_shikomi_keikaku_width: { number: 120 },
        flg_toroku_width: { number: 60 },
        nm_toroku_jotai: { number: 120 },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        inputDateError: { text: MS0019 },
        dateDiffError: { text: MS0686 }        
    });

    App.ui.pagedata.validation("en", {
        // 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 検索条件/製造日（開始）
        con_dt_seizo_from: {
            rules: {
                required: "Manufacture date (start)",
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
                required: "Manufacture date (end)",
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
                required: "Code",
                maxbytelength: 14,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Code"
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
                required: "Line code",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Code"
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
                required: "Magnification",
                //pointlength: [6, 6, false],
                pointlength: [6, 2, false],
                //range: [0, 999999.999999],
                range: [0, 999999.99],
                custom: true
            },
            params: {
                //custom: ["Produce amount, Rest of today", 0, 999999.999999]
                custom: ["Produce amount", 0, 999999.999]
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
                //custom: ["Produce amount, Rest of today", 0, 999999.999999]
                custom: ["Produce amount", 0, 999999.999]
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
                required: "Batch　Number",
                //pointlength: [6, 6, false],
                digits: [6],
                //range: [0, 999999.999999],
                range: [0, 999999],
                custom: true
            },
            params: {
                //custom: ["Produce amount, Rest of today", 0, 999999.999999]
                custom: ["Produce amount", 0, 999999.999]
            },
            messages: {
                required: MS0042,
                //pointlength: MS0440,
                digits:MS0576,
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
                //custom: ["Produce amount, Rest of today", 0, 999999.999999]
                custom: ["Produce amount", 0, 999999.999]
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
                //custom: ["Produce amount, Rest of today", 0, 999999.999999]
                custom: ["Produce amount", 0, 999999.999]
            },
            messages: {
                pointlength: MS0440,
                range: MS0450,
                custom: MS0666
            }
        }
    });

    // 第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // 画面の仕様に応じて以下の画面制御ルールを変更してください。
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