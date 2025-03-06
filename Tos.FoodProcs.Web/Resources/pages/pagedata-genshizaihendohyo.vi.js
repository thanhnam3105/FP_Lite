(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Bảng biến động nguyên vật liệu" },
        dt_keikaku_nonyu: { text: "Ngày cuối cùng tạo tự động kế hoạch nhập" },
        // 明細
        cd_hinmei: { text: "Mã nguyên vật liệu" },
        dt_hizuke: { text: "Ngày tháng" },
        dt_yobi: { text: "Thứ" },
        flg_kyujitsu: { text: "Ngày nghỉ" },
        flg_shukujitsu: { text: "Ngày lễ" },
        su_nonyu_yotei: { text: "Dự định nhập" },
        su_nonyu_jisseki: { text: "Thực tế nhập" },
        su_shiyo_yotei: { text: "Dự định <br>sử dụng" },
        su_shiyo_jisseki: { text: "Thực tế <br>sử dụng" },
        su_seizo_yotei: { text: "Dự định sản xuất" },
        su_seizo_jisseki: { text: "Thực tế sản xuất" },
        su_chosei: { text: "Số lượng điều chỉnh" },
        su_keisanzaiko: { text: "Tồn kho tính toán" },
        su_jitsuzaiko: { text: "Tồn kho thực tế" },
        su_kurikoshi_zan: { text: "Số lượng tồn kho kết chuyển" },
        ts: { text: "Timestamp" },
        cd_toroku: { text: "Người đăng ký" },
        dt_toroku: { text: "Ngày đăng ký" },
        su_ko: { text: "Số sản phẩm" },
        su_iri: { text: "Số lượng bên trong" },
        cd_tani: { text: "Đơn vị nhập"},
        // 検索条件
        hizuke: { text: "Ngày" },
        hinCode: { text: "Mã nguyên vật liệu" },
        hinName: { text: "Tên nguyên vật liệu" },
        nisugata: { text: "Quy cách đóng gói" },
        hacchuLotSize: { text: "Kích cỡ lô hàng đặt" },
        nonyuLeadTime: { text: "Thời gian cung ứng" },
        saiteiZaiko: { text: "Tồn kho tối thiểu" },
        biko: { text: "Ghi chú" },
        shiyoTani: { text: "Đơn vị sử dụng" },
        konyusakiCode: { text: "Mã nhà cung cấp" },
        konyusakiName: { text: "Tên nhà cung cấp" },
        // その他画面項目
        kurikoshiZaiko: { text: "Số lượng tồn kho kết chuyển" },
        kurikoshiZan: { text: "Lượng tồn kết chuyển" },
        nonyuYoteiGokei: { text: "Tổng dự định nhập" },
        nonyuJissekiGokei: { text: "Tổng thực tế nhập" },
        seizoYoteiGokei: { text: "Tổng dự định sản xuất" },
        seizoJissekiGokei: { text: "Tổng thực tế sản xuất" },
        shiyoYoteiGokei: { text: "Tổng dự định sử dụng" },
        shiyoJissekiGokei: { text: "Tổng thực tế sử dụng" },
        choseiGokei: { text: "Tổng lượng điều chỉnh" },
        shiyoIchiran: { text: "Danh sách sử dụng" },
        between: { text: "　～　" },
        total: { text: "Tổng" },
        // その他：文言
        startDate: { text: "Ngày bắt đầu" },
        endDate: { text: "Ngày kết thúc" },
        choseiData: { text: "Adjustment data" },
        zaikoData: { text: "inventory data" },
        initChoseiKey: { text: "Reason、Cost department、Warehouse" },
        initZaikoKey: { text: "Warehouse" },
        // 開始日～終了日の最大期間日数
        maxPeriod: { text: "186" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        initErr: { text: MS0736 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        dt_hizuke_width: { number: 90 },
        dt_yobi_width: { number: 90 },
        su_nonyu_yotei_width: { number: 125 },
        su_nonyu_jisseki_width: { number: 125 },
        su_shiyo_yotei_width: { number: 125 },
        su_shiyo_jisseki_width: { number: 125 },
        su_chosei_width: { number: 130 },
        su_keisanzaiko_width: { number: 130 },
        su_jitsuzaiko_width: { number: 130 },
        total_width: { number: 130 }
        // TODO: ここまで
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
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
                required: "Ngày bắt đầu",
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
                required: "Ngày kết thúc",
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
                required: "Mã sản phẩm",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "Mã sản phẩm"
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
    App.ui.pagedata.operation("vi", {
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