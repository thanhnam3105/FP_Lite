
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "工場マスタ" },
        cd_kojo: { text: "工場コード" },
        nm_kojo: { text: "工場名" },
        dt_nendo_start: { text: "年度開始月" },
        no_yubin1: { text: "郵便番号１" },
        no_yubin2: { text: "郵便番号２" },
        jusho_1: { text: "住所１" },
        jusho_2: { text: "住所２" },
        jusho_3: { text: "住所３" },
        tel_1: { text: "ＴＥＬ１" },
        tel_2: { text: "ＴＥＬ２" },
        fax_1: { text: "ＦＡＸ１" },
        fax_2: { text: "ＦＡＸ２" },
        kbn_haigo_keisan_hoho: { text: "配合計算方法区分" },
        nm_kbn_haigo_keisan_hoho: { text: "配合計算方法区分名" },
        dt_kigen_chokuzen: { text: "期限切れ直前日数" },
        dt_kigen_chikai: { text: "期限切れ近い日数" },
        dt_toroku: { text: "登録日" },
        dt_henko: { text: "更新日" },
        ts: { text: "タイムスタンプ" },
        cd_toroku: { text: "登録者" },
        cd_kaisha: { text: "会社コード" },
        no_com_reader_niuke: { text: "荷受リーダーCOM番号" },
          
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
        nm_kbn_haigo_keisan_hoho_width: { number: 130 },
        dt_kigen_chokuzen_width: { number: 130 },
        dt_kigen_chikai_width: { number: 130 },
        no_com_reader_niuke_width: { number: 140 },
        dt_create_width: { number: 100 },
        dt_update_width: { number: 100 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        dt_nendo_start: {
            rules: {
                required: "年度開始月",
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
                required: "期限切れ直前日数",
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
                required: "期限切れ近い日数",
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
    App.ui.pagedata.operation("ja", {
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
