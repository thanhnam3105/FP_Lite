
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "投放日报" },

        // 【最小値】 日付
        minDate: { text: "2000/01/01" },
        // 【最大値】 日付
        maxDate: { text: "3000/12/31" },
        // 【値】 1日
        oneDay: { text: 86400000 },
        timeNewFormat: { text: "H:i" },
        dt_diff: { text: 31 },
        month_diff: { text: 6 },

        shokuba: { text: "车间" },
        line: { text: "生产线" },
        flg_jisseki: { text: "确定" },
        cd_shikakari_hin: { text: "编号" },
        nm_haigo: { text: "半成品名" },
        cd_line: { text: "生产线编号" },
        nm_line: { text: "生产线名" },
        nm_tani: { text: "使用单位" },
        wt_shikomi_keikaku: { text: "投放量(预定)" },
        wt_shikomi_jisseki: { text: "投放量" },
        ritsu_jisseki: { text: "倍率" },
        //ritsu_jisseki_hasu: { text: "倍率(零数)" },
        ritsu_jisseki_hasu: { text: "倍率(零头数)" },
        //su_batch_jisseki: { text: "批次数" },
        su_batch_jisseki: { text: "锅数" },
        //su_batch_jisseki_hasu: { text: "批次数(零头数)" },
        //su_batch_jisseki_hasu: { text: "锅数(零数)" },
        su_batch_jisseki_hasu: { text: "锅数(零头数)" },
        //wt_zaiko_jisseki: { text: "剩余使用量" },
        wt_zaiko_jisseki: { text: "余量使用量" },
        //wt_shikomi_zan: { text: "当天剩余" },
        wt_shikomi_zan: { text: "当天余量" },
        //no_lot_shikakari: { text: "批量编号" },
        no_lot_shikakari: { text: "批号" },
        dt_seizo: { text: "生产日" },
        //dt_seizo_start: { text: "製造日（开始）" },
        dt_seizo_start: { text: "生产日（开始）" },
        //dt_seizo_end: { text: "製造日（结束）" },
        dt_seizo_end: { text: "生产日（结束）" },
        between: { text: "～" },
        wt_haigo_gokei: { text: "合计配料重量" },
        wt_hitsuyo: { text: "必要量" },
        cd_shokuba: { text: "" },
        shikomi: { text: "投放" },
        seizoJissekiSentaku: { text: "生产实际选择" },
        densoJotai: { text: "已传状态" },
        flg_toroku: { text: "登录确认" },
        //kbn_toroku_jotai: { text: "登录状态" },
        kbn_toroku_jotai: { text: "登录情况" },
        msg_kakuteiData: { text: "确定数据" },
        denso_jokyo: { text: "已传状态" },
        mi_sakusei: { text: "未制作" },
        mi_denso: { text: "未传送" },
        denso_machi: { text: "等传送" },
        denso_zumi: { text: "已传送" },
        //toroku_jokyo: { text: "登录状态" },
        toroku_jokyo: { text: "登录情况" },
        mi_toroku: { text: "未登录" },
        ichibu_mi_toroku: { text: "一部未登录" },
        //toroku_sumi: { text: "已登録" },
        toroku_sumi: { text: "已登录" },
        //lotToroku: { text: "批量登録" },
        lotToroku: { text: "批号登録" },
        lotTorokuZenbu: { text: "全检查/取消" },

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

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 検索条件/製造日
        con_dt_seizo_from: {
            rules: {
                required: "生产日（开始）",
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
                required: "生产日（结束）",
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
                required: "编号",
                maxbytelength: 14,
                alphanum: true,
                custom: true
            },
            params: {
                custom: "编号"
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
                required: "生产线编号",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "编号"
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
                //custom: ["投放量、当天剩余", 0, 999999.999999]
                custom: ["投放量", 0, 999999.999]
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
                //custom: ["投放量、当天剩余", 0, 999999.999999]
                custom: ["投放量", 0, 999999.999]
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
                //custom: ["投放量、当天剩余", 0, 999999.999999]
                custom: ["投放量", 0, 999999.999]
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
                //custom: ["投放量、当天剩余", 0, 999999.999999]
                custom: ["投放量", 0, 999999.999]
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
                //custom: ["投放量、当天剩余", 0, 999999.999999]
                custom: ["投放量", 0, 999999.999]
            },
            messages: {
                pointlength: MS0440,
                range: MS0450,
                custom: MS0666
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
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
