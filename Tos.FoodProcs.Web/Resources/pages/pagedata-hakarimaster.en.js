(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Scale Master Catalogue" },
        flg_mishiyo_kensaku: { text: "Display unused" },
        cd_hakari: { text: "Scale code" },
        nm_hakari: { text: "Type" },
        nm_tani: { text: "Unit" },
        cd_tani: { text: "Unit code" },
        joken_tushin: { text: "Communication condition" },
        kbn_baurate: { text: "Baud rate" },
        kbn_parity: { text: "Parity" },
        kbn_databit: { text: "Length of data" },
        kbn_stopbit: { text: "Stop bit" },
        kbn_handshake: { text: "Hand shake" },
        nm_antei: { text: "Stability" },
        nm_fuantei: { text: "Unstability" },
        su_keta: { text: "Figure" },
        no_ichi_juryo: { text: "Weight" },
        su_ichi_fugo: { text: "Mark" },
        cd_fundo: { text: "Balance weight code" },
        wt_fundo: { text: "Standard weight" },
        disp_fugo: { text: "Mark output" },
        flg_fugo: { text: "Mark not output" },
        flg_mishiyo: { text: "Unused" },
        flg_hakari_check: { text: "秤点検" },
        flg_mishiyo_shosai: { text: "When not usage" },
        dt_create: { text: "Registration date" },
        cd_create: { text: "Registrant" },
        dt_update: { text: "Update date" },
        cd_update: { text: "Updater" },
        no_com: { text: "Number of COM ports" },
        ts: { text: "Time stamp" },

        dispFugoMsg: { text: "undo" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        saveConfirm: { text: MS0064 },
        saveComplete: { text: MS0036 },
        deleteConfirm: { text: MS0068 },
        deleteComplete: { text: MS0039 },
        unloadWithoutSave: { text: MS0066 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hakari_width: { number: 80 },
        nm_hakari_width: { number: 200 },
        nm_tani_width: { number: 80 },
        nm_kbn_baurate_width: { number: 100 },
        nm_kbn_parity_width: { number: 100 },
        nm_kbn_databit_width: { number: 100 },
        nm_kbn_stopbit_width: { number: 120 },
        nm_kbn_handshake_width: { number: 120 },
        nm_antei_width: { number: 60 },
        nm_fuantei_width: { number: 70 },
        no_ichi_juryo_width: { number: 50 },
        su_keta_width: { number: 50 },
        su_ichi_fugo_width: { number: 50 },
        wt_fundo_width: { number: 120 },
        flg_fugo_width: { number: 110 },
        flg_mishiyo_width: { number: 60 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hakari: {
            rules: {
                required: "Scale code",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0021
            }
        },
        nm_antei: {
            rules: {
                required: "Stability name",
                alphanum: true,
                maxlength: 6
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0021
            }
        },
        nm_hakari: {
            rules: {
                required: "Type",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        nm_fuantei: {
            rules: {
                required: "Unstability name",
                alphanum: true,
                maxlength: 6
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0021
            }
        },
        cd_tani: {
            rules: {
                required: "Unit"
            },
            messages: {
                required: MS0042
            }
        },
        no_ichi_juryo: {
            rules: {
                required: "Weight",
                number: true,
                pointlength: [4, 0, true]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        kbn_baurate: {
            rules: {
                required: "Baud rate"
            },
            messages: {
                required: MS0042
            }
        },
        su_keta: {
            rules: {
                required: "Figure",
                number: true,
                pointlength: [4, 0, true]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        kbn_parity: {
            rules: {
                required: "Parity"
            },
            messages: {
                required: MS0042
            }
        },
        su_ichi_fugo: {
            rules: {
                required: "Mark",
                number: true,
                pointlength: [4, 0, true]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        kbn_databit: {
            rules: {
                required: "Length of data"
            },
            messages: {
                required: MS0042
            }
        },
        cd_fundo: {
            rules: {
                required: "Standard weight"
            },
            messages: {
                required: MS0042
            }
        },
        kbn_stopbit: {
            rules: {
                required: "Stop bit"
            },
            messages: {
                required: MS0042
            }
        },
        flg_fugo: {
            rules: {
                required: "Mark output"
            },
            messages: {
                required: MS0042
            }
        },
        kbn_handshake: {
            rules: {
                required: "Hand shake"
            },
            messages: {
                required: MS0042
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        add: {
            Viewer: { visible: false }
        },
        save: {
            Viewer: { visible: false }
        },
        del: {
            Viewer: { visible: false }
        }
        // TODO: ここまで
    });
})();