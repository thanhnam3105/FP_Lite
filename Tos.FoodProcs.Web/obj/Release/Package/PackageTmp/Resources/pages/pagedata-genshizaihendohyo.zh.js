(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原材料变动表" },
        dt_keikaku_nonyu: { text: "入库计划自动作成最后一天" },
        // 明細
        cd_hinmei: { text: "品名编号" },
        dt_hizuke: { text: "月日" },
        dt_yobi: { text: "星期" },
        flg_kyujitsu: { text: "假日" },
        flg_shukujitsu: { text: "节日" },
        su_nonyu_yotei: { text: "入库预定" },
        su_nonyu_jisseki: { text: "入库实际" },
        su_shiyo_yotei: { text: "使用预定" },
        su_shiyo_jisseki: { text: "使用实际" },
        su_seizo_yotei: { text: "生产预定" },
        su_seizo_jisseki: { text: "生产实际" },
        su_chosei: { text: "调整数" },
        su_keisanzaiko: { text: "计算库存数" },
        su_jitsuzaiko: { text: "实际库存数" },
        su_kurikoshi_zan: { text: "转入库存" },
        ts: { text: "时间标记" },
        cd_toroku: { text: "登录者" },
        dt_toroku: { text: "登录日期" },
        su_ko: { text: "个数" },
        su_iri: { text: "装箱数" },
        cd_tani: { text: "入库单位" },
        // 検索条件
        hizuke: { text: "日期" },
        hinCode: { text: "品名编号" },
        hinName: { text: "品名" },
        nisugata: { text: "包装" },
        //hacchuLotSize: { text: "订货批量大小" },
        hacchuLotSize: { text: "订货批号大小" },
        nonyuLeadTime: { text: "入库期" },
        saiteiZaiko: { text: "最小库存" },
        biko: { text: "备注" },
        shiyoTani: { text: "使用单位" },
        konyusakiCode: { text: "购买商编号" },
        konyusakiName: { text: "购买商名" },
        // その他：画面項目
        kurikoshiZaiko: { text: "转入库存" },
        kurikoshiZan: { text: "转入余量" },
        nonyuYoteiGokei: { text: "入库预定合计" },
        nonyuJissekiGokei: { text: "入库实际合计" },
        seizoYoteiGokei: { text: "生产预定合计" },
        seizoJissekiGokei: { text: "生产实际合计" },
        shiyoYoteiGokei: { text: "生产预定合计" },
        shiyoJissekiGokei: { text: "使用实际合计" },
        choseiGokei: { text: "调整数合计" },
        shiyoIchiran: { text: "使用一览" },
        between: { text: "　～　" },
        total: { text: "合计" },
        // その他：文言
        startDate: { text: "开始日" },
        endDate: { text: "结束日" },
        choseiData: { text: "调整数据" },
        zaikoData: { text: "库存输入" },
        initChoseiKey: { text: "理由,原价中心,仓库" },
        initZaikoKey: { text: "仓库" },
        // 開始日～終了日の最大期間日数
        maxPeriod: { text: "186" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        initErr: { text: MS0736 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        dt_hizuke_width: { number: 90 },
        dt_yobi_width: { number: 40 },
        su_nonyu_yotei_width: { number: 125 },
        su_nonyu_jisseki_width: { number: 125 },
        su_shiyo_yotei_width: { number: 125 },
        su_shiyo_jisseki_width: { number: 125 },
        su_chosei_width: { number: 125 },
        su_keisanzaiko_width: { number: 125 },
        su_jitsuzaiko_width: { number: 125 },
        total_width: { number: 130 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        su_nonyu_yotei: {
            rules: {
                number: MS0441,
 //                pointlength: [6, 2, true],
 //                range: [0, 999999.99]
                pointlength: [6, 3, true],
                range: [0, 999999.999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        su_chosei: {
            rules: {
                number: MS0441,
//                pointlength: [6, 6, true],
//                range: [-999999.999999, 999999.999999]
                pointlength: [6, 3, true],
                range: [-999999.999, 999999.999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        su_jitsuzaiko: {
            rules: {
                number: MS0441,
//                pointlength: [8, 6, true],
//                range: [0, 99999999.999999]
                pointlength: [8, 3, true],
                range: [0, 99999999.999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        // 検索条件
        hizuke: {
            rules: {
                required: "开始日",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        hizuke_to: {
            rules: {
                required: "结束日",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        hinCode: {
            rules: {
                required: "商品编号",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "商品编号"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                custom: MS0037
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
