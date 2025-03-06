(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "生产日报" },
        _seizo: { text: "生产" },
        dt_seizo: { text: "生产日" },
        shokuba: { text: "车间" },
        line: { text: "生产线" },
        flg_denso: { text: "传送" },
        //no_lot_seihin: { text: "批量编号" },
        no_lot_seihin: { text: "批号" },
        flg_jisseki: { text: "确定" },
        cd_hinmei: { text: "编号" },
        nm_hinmei: { text: "生产名" },
        cd_line: { text: "生产线编号" },
        nm_line: { text: "生产线名" },
        su_seizo_yotei: { text: "生产预定数" },
        su_seizo_jisseki: { text: "生产实际数" },
        dd_shomi_kigen: { text: "保质期" },
        //no_lot_seihin: { text: "批量编号" },
        no_lot_seihin: { text: "批号" },
        kbn_denso: { text: "已传送" },
        dt_update: { text: "登录日" },
        flg_mishiyo: { text: "未使用" },
        ts: { text: "时间标记" },
        msg_newLine: { text: "新行" },
        //batch: { text: "批次数量" },
        //batch: { text: "批次数" },
        batch: { text: "锅数" },
        bairitsu: { text: "倍率" },
        //no_lot_hyoji: { text: "显示批量编号" },
        no_lot_hyoji: { text: "显示批号" },
        check_reflect: { text: "显示对象" },
        csReflect: { text: "C/S数显示" },
        msg_param: { text: "的生产实际数" },
        dd_shomi: { text: "賞味期間" },
        su_zaiko: { text: "在庫量" },
        su_shiyo: { text: "使用量" },
        uchiwake: { text: "内訳" },
        // 画面の仕様に応じて以下の画面メッセージを変更してください。
        shomiErr: { text: MS0019 },
        deleteConfirm: { text: MS0752 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        flg_jisseki_width: { number: 55 },
        su_seizo_yotei_width: { number: 105 },
        su_seizo_jisseki_width: { number: 105 },
        dd_shomi_kigen_width: { number: 90 },
        dt_seizo_width: { number: 80 },

        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        moreOtherRows: { text: "「其他{0}件」" },
        detailMessageMS0783: { text: "产品批号：{0} 半成品批号：{1} 投放日：{2}<br>" }
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_seizo: {
            rules: {
                required: "生产日",
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
                required: "编号",
                maxbytelength: 14,
                alphanum: true//,
                //custom: true
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
        cd_line: {
            rules: {
                required: "生产线编号",
                maxbytelength: 10,
                alphanum: true//,
                //custom: true
            },
            params: {
                custom: "生产线编号"
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
                required: "生产实际数",
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
                custom: "保质期"
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
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
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
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
