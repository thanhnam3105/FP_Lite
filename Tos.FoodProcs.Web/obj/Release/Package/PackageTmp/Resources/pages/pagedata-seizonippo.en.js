
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Daily Report Of Productions" },
        _seizo: { text: "Manufacture" },
        dt_seizo: { text: "Date" },
        shokuba: { text: "Workplace" },
        line: { text: "Line" },
        flg_denso: { text: "Transmission" },
        no_lot_seihin: { text: "Lot No." },
        flg_jisseki: { text: "Confirm" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Product name" },
        cd_line: { text: "Line code" },
        nm_line: { text: "Line name" },
        su_seizo_yotei: { text: "Quantity of<br>manufacture plans" },
        su_seizo_jisseki: { text: "Quantity of<br>actual manufactures" },
        //dd_shomi_kigen: { text: "Expiry<br>date" },
        dd_shomi_kigen: { text: "Expiration<br>date" },
        no_lot_seihin: { text: "Lot No." },
        kbn_denso: { text: "Transmitted" },
        dt_update: { text: "Registration date" },
        flg_mishiyo: { text: "Unused" },
        ts: { text: "Time stamp" },
        msg_newLine: { text: "new line" },
        batch: { text: "Quantity of<br>batches" },
        bairitsu: { text: "Magnification" },
        no_lot_hyoji: { text: "External Lot No." },
        check_reflect: { text: "Reflect<br>target" },
        csReflect: { text: "C/S Reflect" },
        msg_param: { text: "actual manufactures of" },
        //dd_shomi: { text: "Expiry<br>day" },
        //dd_shomi: { text: "Shelf life<br />before opened" },
        dd_shomi: { text: "Expiration date" },
        su_zaiko: { text: "Balance quantity" },
        su_shiyo: { text: "Usage quantity" },
        uchiwake: { text: "detail" },
        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        shomiErr: { text: MS0019 },
        deleteConfirm: { text: MS0752 },
        // 画面の仕様に応じて以下の列幅を変更してください。
        flg_jisseki_width: { number: 95 },
        su_seizo_yotei_width: { number: 130 },
        su_seizo_jisseki_width: { number: 140 },
        dd_shomi_kigen_width: { number: 90 },
        dt_seizo_width: { number: 120 },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        moreOtherRows: { text: "(More other {0} rows)" },
        //detailMessageMS0783: { text: "● Product lot No.: {0} Progressing product lot No.: {1} Produce date: {2}<br>" }
        detailMessageMS0783: { text: "● Product lot No.: {0} Progressing product lot No.: {1} Production date: {2}<br>" }
    });

    App.ui.pagedata.validation("en", {
        // 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_seizo: {
            rules: {
                required: "Manufacture date",
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
                required: "Code",
                maxbytelength: 14,
                alphanum: true//,
                //custom: true
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
        cd_line: {
            rules: {
                required: "Line code",
                maxbytelength: 10,
                alphanum: true//,
                //custom: true
            },
            params: {
                custom: "Line code"
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
                required: "Number of actual manufactures",
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
                //required: "Expiry date",
                datestring: true,
                lessdate: new Date("1969/12/31"),
                greaterdate: new Date("3001/01/01")
            },
            params: {
                //custom: "Expiry date"
                custom: "Expiration date"
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
                required: "Usage quantity",
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
    App.ui.pagedata.operation("en", {
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