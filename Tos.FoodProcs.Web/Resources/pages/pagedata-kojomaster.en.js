
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Plant Master" },
        cd_kojo: { text: "Code" },
        nm_kojo: { text: "Name" },
        dt_nendo_start: { text: "Period<br>start month" },
        no_yubin1: { text: "ZIP code1" },
        no_yubin2: { text: "ZIP code2" },
        jusho_1: { text: "Address1" },
        jusho_2: { text: "Address2" },
        jusho_3: { text: "Address3" },
        tel_1: { text: "TEL1" },
        tel_2: { text: "TEL2" },
        fax_1: { text: "FAX1" },
        fax_2: { text: "FAX2" },
        kbn_haigo_keisan_hoho: { text: "Calculation method<br>type of formula" },
        nm_kbn_haigo_keisan_hoho: { text: "Calculation method" },
        dt_kigen_chokuzen: { text: "Shelf life<br>(very near)" },
        dt_kigen_chikai: { text: "Shelf life<br>(near)" },
        dt_toroku: { text: "Registration<br>date" },
        dt_henko: { text: "Update date" },
        ts: { text: "Time stamp" },
        cd_toroku: { text: "Registrant" },
        cd_kaisha: { text: "Company code" },
        no_com_reader_niuke: { text: "COM No. of<br>receipt reader" },
          
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        checkDateKigen: { text: MS0618 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_kojo_width: { number: 100 },
        nm_kojo_width: { number: 250 },
        dt_nendo_start_width: { number: 75 },
        no_yubin1_width: { number: 90 },
        no_yubin2_width: { number: 90 },
        nm_jusho_1_width: { number: 215 },
        nm_jusho_2_width: { number: 215 },
        nm_jusho_3_width: { number: 215 },
        no_tel_1_width: { number: 110 },
        no_tel_2_width: { number: 110 },
        no_fax_1_width: { number: 110 },
        no_fax_2_width: { number: 110 },
        kbn_haigo_keisan_hoho_width: { number: 110 },
        nm_kbn_haigo_keisan_hoho_width: { number: 190 },
        dt_kigen_chokuzen_width: { number: 170 },
        dt_kigen_chikai_width: { number: 130 },
        no_com_reader_niuke_width: { number: 110 },
        dt_create_width: { number: 100 },
        dt_update_width: { number: 100 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        dt_nendo_start: {
            rules: {
                required: "New year start month",
                month: true,
                maxbytelength: 2
            },
            messages: {
                required: MS0042,
                month: MS0449,
                maxbytelength: MS0012
            }
        },
        no_yubin1: {
            rules: {
                haneisukigo: true,
                maxbytelength: 10
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_yubin2: {
            rules: {
                haneisukigo: true,
                maxbytelength: 10
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        nm_jusho_1: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_jusho_2: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_jusho_3: {
            rules: {
                maxbytelength: 30
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        no_tel_1: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_tel_2: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_fax_1: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_fax_2: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        dt_kigen_chokuzen: {
            rules: {
                //required: "Very near to expiry date",
                required: "Very near to expiration date",
                number: true,
                digits: [2],
                range: [1, 99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                digits: MS0576,
                range: MS0450
            }
        },
        dt_kigen_chikai: {
            rules: {
                //required: "Near to expiry date",
                required: "Near to expiration date",
                number: true,
                digits: [2],
                range: [1, 99]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                digits: MS0576,
                range: MS0450
            }
        },
        no_com_reader_niuke: {
            rules: {
                number: true,
                digits: [2],
                range: [1, 99]
            },
            messages: {
                number: MS0441,
                digits: MS0576,
                range: MS0450
            }
        }

        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // 一覧
        colchange: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }

        },
        // 詳細
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        detail: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

    //// ページデータ -- End
})();
