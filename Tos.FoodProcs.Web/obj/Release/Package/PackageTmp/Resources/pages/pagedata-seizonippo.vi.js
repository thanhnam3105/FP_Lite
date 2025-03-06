
(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Báo cáo sản xuất sản phẩm hằng ngày" },
        _seizo: { text: "Sản xuất" },
        dt_seizo: { text: "Ngày sản xuất" },
        shokuba: { text: "Bộ phận SX", tooltip: "Bộ phận sản xuất" },
        line: { text: "Dây chuyền" },
        flg_denso: { text: "Hóa đơn" },
        no_lot_seihin: { text: "Số lô" },
        flg_jisseki: { text: "Duyệt" },
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên sản phẩm" },
        cd_line: { text: "Mã dây chuyền" },
        nm_line: { text: "Tên dây chuyền" },
        su_seizo_yotei: { text: "Số lượng sản xuất<br>dự định" },
        su_seizo_jisseki: { text: "Số lượng sản xuất<br>thực tế" },
        //dd_shomi_kigen: { text: "Expiry<br>date" },
        dd_shomi_kigen: { text: "Hạn sử dụng" },
        no_lot_seihin: { text: "Số lô" },
        kbn_denso: { text: "Đã gửi đi" },
        dt_update: { text: "Ngày đăng ký" },
        flg_mishiyo: { text: "Không sử dụng" },
        ts: { text: "Time stamp" },
        msg_newLine: { text: "Dòng mới" },
        batch: { text: "Số mẻ sản xuất" },
        bairitsu: { text: "Bội suất" },
        no_lot_hyoji: { text: "External Lot No." },
        check_reflect: { text: "Đối tượng phản ánh" },
        csReflect: { text: "Phản ánh số lượng C/S" },
        msg_param: { text: "Số lượng thực tế sản xuất của ..." },
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
        dt_seizo_width: { number: 100 },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        moreOtherRows: { text: "(More other {0} rows)" },
        //detailMessageMS0783: { text: "● Product lot No.: {0} Progressing product lot No.: {1} Produce date: {2}<br>" }
        detailMessageMS0783: { text: "● Product lot No.: {0} Progressing product lot No.: {1} Production date: {2}<br>" }
    });

    App.ui.pagedata.validation("vi", {
        // 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_seizo: {
            rules: {
                required: "Ngày sản xuất",
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
                required: "Mã",
                maxbytelength: 14,
                alphanum: true//,
                //custom: true
            },
            params: {
                custom: "Mã"
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
                required: "Mã dây chuyền",
                maxbytelength: 10,
                alphanum: true//,
                //custom: true
            },
            params: {
                custom: "Mã dây chuyền"
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
                required: "Số lượng thực tế sản xuất",
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
    App.ui.pagedata.operation("vi", {
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