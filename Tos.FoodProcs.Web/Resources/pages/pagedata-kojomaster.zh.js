
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "工厂主表" },
        cd_kojo: { text: "工厂编号" },
        nm_kojo: { text: "工厂名" },
        dt_nendo_start: { text: "年度开始月" },
        no_yubin1: { text: "邮政编码１" },
        no_yubin2: { text: "邮政编码２" },
        jusho_1: { text: "住址１" },
        jusho_2: { text: "住址２" },
        jusho_3: { text: "住址３" },
        tel_1: { text: "ＴＥＬ１" },
        tel_2: { text: "ＴＥＬ２" },
        fax_1: { text: "传真１" },
        fax_2: { text: "传真２" },
        kbn_haigo_keisan_hoho: { text: "配料计算方法区分" },
        nm_kbn_haigo_keisan_hoho: { text: "配料计算方法区分名" },
        dt_kigen_chokuzen: { text: "期限太近的日数" },
        dt_kigen_chikai: { text: "期限很近的日数" },
        dt_toroku: { text: "登录日" },
        dt_henko: { text: "更新日" },
        ts: { text: "时间标记" },
        cd_toroku: { text: "登录者" },
        cd_kaisha: { text: "公司编号" },
        //no_com_reader_niuke: { text: "领货读入器COM编码" },
        no_com_reader_niuke: { text: "入库读入器COM编码" },

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

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。

        dt_nendo_start: {
            rules: {
                required: "年度开始月",
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
                required: "期限太近的日数",
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
                required: "期限很近的日数",
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
    App.ui.pagedata.operation("zh", {
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
