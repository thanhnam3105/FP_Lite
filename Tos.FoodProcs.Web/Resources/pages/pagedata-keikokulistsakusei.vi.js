(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Tạo danh sách cảnh báo" },
        // 検索条件
        dt_target: { text: "Ngày bắt đầu" },
        dt_target_to: { text: "Ngày kết thúc" },
        kbn_hin: { text: "Loại sản phẩm" },
        hin_bunrui: { text: "Nhóm sản phẩm" },
        kurabasho: { text: "Kho" },
        hinmei: { text: "Tên sản phẩm" },
        keikoku_min: { text: "Danh sách cảnh báo" },
        keikoku_max: { text: "TKTĐ cũng cảnh báo", tooltip: "Tồn kho tối đa cũng cảnh báo" },
        zenZaiko_tojitsuShiyo: { text: "TK hôm trước - LSD hôm nay", tooltip: "Tồn kho hôm trước - Lượng sử dụng hôm nay" },
        allGenshizai: { text: "Hiển thị  tất cả NVL", tooltip: "Hiển thị tất cả nguyên vật liệu" },
        considersLeadtime: { text: "Thêm thời gian cung ứng" },
        between: { text: "　～　" },
        // 一覧
        dt_hizuke: { text: "Ngày/Tháng" },
        dt_hizukeUS: { text: "Ngày/Tháng" },
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên" },
        nm_nisugata_hyoji: { text: "Quy cách đóng gói" },
        tani_shiyo: { text: "Đơn vị <br>sử dụng" },
        su_zaiko: { text: "Tồn kho" },
        su_zaiko_min: { text: "Tồn kho tối thiểu" },
        su_zaiko_max: { text: "Tồn kho tối đa" },
        nm_torihiki: { text: "Tên bên mua" },
        // ボタン
        hendohyo: { text: "Bảng biến động" },
        zaiko_update: { text: "Cập nhật tồn kho tính toán" },
        // 隠し項目など
        dt_hizuke_full: { text: "Năm/Tháng/Ngày" },
        // 計算在庫作成時の作成できる最大期間日数
        maxPeriod: { text: "184" },
        //maxPeriod: { text: "32" },  // TODO：レスポンス問題が解決するまでは32日間
        splitDays: { number: 7 },  // 分割する日数
        // TODO: ここまで
        listDateFormat: { text: "Ngày/Tháng" },   // 明細．日付のフォーマット
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        limitOver: { text: MS0011 },
        startConfirm: { text: MS0695 },
        allGenshizaiConfirm: { text: MS0679 },
        creatCompletion: { text: MS0696 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        each_lang_width: { number: 150 },
        item_list_left_width: { number: 450 },
        dt_hizuke_width: { number: 90 },
        zenZaiko_tojitsuShiyo_width: { number: 270 },
        keikoku_max_width: { number: 180 },
        allGenshizai_width: { number: 200 },
        cd_hinmei_width: { number: 90 },
        nm_hinmei_width: { number: 250 },
        nm_nisugata_hyoji_width: { number: 159 },
        tani_shiyo_width: { number: 90 },
        su_zaiko_width: { number: 110 },
        su_zaiko_min_width: { number: 110 },
        su_zaiko_max_width: { number: 110 },
        nm_torihiki_width: { number: 200 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_target: {
            rules: {
                required: "Ngày",
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0004,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        dt_target_to: {
            rules: {
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        hinmei: {
            rules: {
                maxbytelength: 100
            },
            messages: {
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        keisanzaikoUpdate: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        search: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false }
        },
        excel: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false }
        },
        hendohyo: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();