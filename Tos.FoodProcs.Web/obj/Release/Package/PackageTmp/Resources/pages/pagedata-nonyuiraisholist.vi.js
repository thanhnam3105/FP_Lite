(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Danh sách phiếu yêu cầu nhập" },
        // ヘッダー
        hachuNo: { text: "MS đặt hàng: ", tooltip: "Mã số đặt hàng" },
        renrakusaki: { text: "Địa chỉ liên hệ: " },
        renrakusaki_tel: { text: "TEL" },
        renrakusaki_fax: { text: "FAX" },
        nohinsaki: { text: "Bên nhận: " },
        // 印刷レイアウト選択
        print_layout: { text: "Bố trí: " },
        layout_yoko: { text: "Ngang" },
        layout_tate: { text: "Dọc" },
        // 検索条件
        dt_sakusei_kaishi: { text: "Ngày bắt đầu tạo" },
        nm_torihiki: { text: "Khách hàng" },
        torihiki_tani: { text: "(Số lượng nhập)" },
        // 一覧
        cd_hinmei: { text: "Mã sản phẩm" },
        nm_hinmei: { text: "Tên sản phẩm" },
        nm_nisugata_hyoji: { text: "Quy cách đóng gói" },
        tani_nonyu: { text: "Đơn vị" },
        nm_bunrui: { text: "Loại" },
        dt_nonyu: { text: "Tháng/Ngày" },
        su_nonyu: { text: "Số lượng" },
        juryo: { text: "Trọng lượng (Kg)" },
        // ボタン
        allPrint: { text: "In toàn bộ" },
        // 隠し項目など
        // TODO: ここまで
        listDateFormat: { text: "d/m（D）" },   // 明細．日付のフォーマット
        listDateFormatUS: { text: "m/d（D）" },   // 明細．日付のフォーマット
        hachuSaibanKbn: { text: "12" },  // 発注番号の採番区分
        hachuPrefix: { text: "H" },      // 採番区分のプレフィックス
        // PDF：ページ上限数：2013.12.26時点100枚
        pageMaximums: { text: "100" },
        // PDF：確認ダイアログを表示する条件ページ数：2013.12.26時点10枚
        pageCautions: { text: "10" },
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        notOperate: { text: MS0655 },
        pageMaximumsOver: { text: MS0680 },
        pageCautionsOverConfirm: { text: MS0654 },
        printConfirm: { text: MS0223 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hinmei_width: { number: 120 }
        // TODO: ここまで
    });
    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        pdf: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        pdfAll: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();