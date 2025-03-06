(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "製造日報" },
        _seizo: { text: "製造" },
        dt_seizo: { text: "製造日" },
        shokuba: { text: "職場" },
        line: { text: "ライン" },
        flg_denso: { text: "伝" },
        no_lot_seihin: { text: "ロット番号" },
        flg_jisseki: { text: "確定" },
        cd_hinmei: { text: "コード" },
        nm_hinmei: { text: "製品名" },
        cd_line: { text: "ラインコード" },
        nm_line: { text: "ライン名" },
        su_seizo_yotei: { text: "製造予定数" },
        su_seizo_jisseki: { text: "製造実績数" },
        dd_shomi_kigen: { text: "賞味期限" },
        no_lot_seihin: { text: "ロット番号" },
        kbn_denso: { text: "伝送済" },
        dt_update: { text: "登録日" },
        flg_mishiyo: { text: "未使用" },
        ts: { text: "タイムスタンプ" },
        msg_newLine: { text: "新規行" },
        batch: { text: "バッチ数" },
        bairitsu: { text: "倍率" },
        no_lot_hyoji: { text: "表示ロットNo" },
        check_reflect: { text: "反映対象" },
        csReflect: { text: "C/S数反映" },
        msg_param: { text: "の製造実績数" },
        dd_shomi: { text: "賞味期間" },
        su_zaiko: { text: "在庫量" },
        su_shiyo: { text: "使用量" },
        uchiwake: { text: "内訳" },
        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        shomiErr: { text: MS0019 },
        deleteConfirm: { text: MS0752 },
        // 画面の仕様に応じて以下の列幅を変更してください。
        flg_jisseki_width: { number: 55 },
        su_seizo_yotei_width: { number: 105 },
        su_seizo_jisseki_width: { number: 105 },
        dd_shomi_kigen_width: { number: 90 },
        dt_seizo_width: { number: 80 },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        moreOtherRows: { text: "「他{0}件」" },
        detailMessageMS0783: { text: "● 製品ロット番号：{0} 仕掛品ロットNo：{1} 仕込日：{2}<br>" }
    });

    App.ui.pagedata.validation("ja", {
        // 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_seizo: {
            rules: {
                required: "製造日",
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
        cd_hinmei: {
            rules: {
                required: "コード",
                maxbytelength: 14,
                alphanum: true//,
                //custom: true
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
        cd_line: {
            rules: {
                required: "ラインコード",
                maxbytelength: 10,
                alphanum: true//,
                //custom: true
            },
            params: {
                custom: "ラインコード"
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0005,
                custom: MS0049
            }
        },
        su_seizo_jisseki: {
            rules: {
                required: "製造実績数",
                range: [0, 99999999.999],
                pointlength: [8, 3, false]
            },
            params: {
                pointlength: [8, 3, false]
            },
            messages: {
                required: MS0042,
                range: MS0450,
                pointlength: MS0440
            }
        },
        dt_shomi: {
            rules: {
                //required: "賞味期限",
                datestring: true,
                lessdate: new Date("1969/12/31"),
                greaterdate: new Date("3001/01/01")
            },
            params: {
                custom: "賞味期限"
            },
            messages: {
                //required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247,
                custom: MS0042
            }
        },
        no_lot_hyoji: {
            rules: {
                maxbytelength: 30,
                alphakigo: true
            },
            messages: {
                maxbytelength: MS0012,
                alphakigo: MS0005
            }
        },
        su_shiyo: {
            rules: {
                required: "使用量",
                range: [0.000, 99999.999],
                pointlength: [9, 3, false]
            },
            messages: {
                required: MS0042,
                range: MS0450,
                pointlength: MS0576
            }
        }
    });

    // 第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
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
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        hinmei: {
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        line: {
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        csReflect: {
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
