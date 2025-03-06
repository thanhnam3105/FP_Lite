    (function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Tạo phiếu yêu cầu nhập" },
        // 作成条件
        dt_sakusei_kaishi: { text: "Ngày bắt đầu tạo" },
        select_torihiki: { text: "Chọn khách hàng" },
        select_hinmei: { text: "Chọn sản phẩm" },
        select_all_print: { text: "In tất cả dữ liệu" },
        select_torihiki_hinmei: { text: "Chọn KH/SP", tooltip: "Chọn khách hàng/sản phẩm" },
        yotei_nashi: { text: "Xuất cả những sản phẩm không có dự định" },
        bunruigoto: { text: "Chuyển trang theo từng loại" },
        nohinsaki: { text: "Bên nhận hàng　Chỉ định nơi thay thế" },
        comment: { text: "Comment" },
        // ボタン
        nohinsakiIchiran: { text: "Danh sách bên nhận hàng" },
        teikeibunIchiran: { text: "Danh sách comment thường dùng" },
        // 隠し項目など
        comment_area: { text: "Cột nhập comment" },
        selectCriteria: { text: "Điều kiện xuất" },
        // PDF：ページ上限数：2013.12.26時点100枚
        pageMaximums: { text: "100" },
        // PDF：確認ダイアログを表示する条件ページ数：2013.12.26時点10枚
        pageCautions: { text: "10" },
        // 出力条件の定数
        selectTorihiki: { text: "1" },
        selectHinmei: { text: "2" },
        selectAllPrint: { text: "3" },
        selectToriHin: { text: "4" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        printConfirm: { text: MS0223 },
        pageCautionsOverConfirm: { text: MS0654 },
        pageMaximumsOver: { text: MS0680 },
        selectRequired: { text: MS0042 },
        selectNone: { text: MS0044 },
        notOperate: { text: MS0655 },
        reqMsgNohinsaki: { text: "Khi checkbox bật ON là bên nhận hàng" },
        reqMsgComment: { text: "Khi checkbox bật ON là comment" }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        dt_sakusei_kaishi: {
            rules: {
                required: "Ngày bắt đầu tạo",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        comment_area: {
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
        select: {
            Editor: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        nohinsakiIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        teikeibunIchiran: {
            Editor: { visible: false },
            Viewer: { visible: false },
            guest: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();