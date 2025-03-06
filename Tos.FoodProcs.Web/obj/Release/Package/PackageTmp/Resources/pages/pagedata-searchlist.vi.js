(function () {
    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "ID0003:Danh sách master thành phần" },
        combDetail: { text: "Chi tiết thành phần" },
        categoryCode: { text: "Mã loại" },
        categoryName: { text: "Tên loại" },
        articleDivisionCD: { text: "Mã loại bán thành phẩm" },
        articleDivisionName: { text: "Tên loại bán thành phẩm" },
        combinationCD: { text: "Mã thành phần" },
        combinationName: { text: "Tên thành phần" },
        combinationShortName: { text: "Tên thành phần (Gọi tắt)" },
        combinationRomaName: { text: "Tên thành phần (Romaji)" },
        yield: { text: "Bảo lưu" },
        baseWeight: { text: "Trọng lượng cơ bản" },
        vwDivision: { text: "Phân loại V/W" },
        specificGravity: { text: "Tỉ trọng" },
        facilitiesCD: { text: "Mã thiết bị" },
        facilitiesName: { text: "Tên thiết bị" },
        maxWeight: { text: "Lượng tối đa cần chuẩn bị" },
        lineCode: { text: "Mã dây chuyền" },
        lineName: { text: "Tên dây chuyền" },
        priority: { text: "Thứ tự ưu tiên" },
        combinationID: { text: "Số thứ tự" },
        other: { text: "Nhà máy khác" },
        recipe: { text: "Công thức" },
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        combinationCD: {
            rules: { required: true },
            messages: { required: "Bắt buộc nhập mã thành phần." }
        },
        combinationName: {
            rules: { required: true },
            messages: { required: "Bắt buộc nhập tên thành phần." }
        },
        yield: { 
            rules: { digits: true },
            messages: { digits: "Chỉ giữ lại giá trị số." }
        },
        categoryName: {
            rules: { required: true },
            messages: { required: "Bắt buộc nhập tên loại." }
        },
        articleDivisionName: {
            rules: { required: true },
            messages: { required: "Bắt buộc nhập tên loại bán thành phẩm." }
        },
        facilitiesName: {
            rules: { required: true },
            messages: { required: "Bắt buộc nhập tên thiết bị." }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        // TODO: ここまで
    });
})();