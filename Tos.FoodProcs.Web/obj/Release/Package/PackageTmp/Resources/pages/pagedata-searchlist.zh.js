(function () {
    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "ID0003:配料主表一览" },
        combDetail: { text: "配料明细" },
        categoryCode: { text: "分类编号" },
        categoryName: { text: "分类名" },
        articleDivisionCD: { text: "半成品分类编号" },
        articleDivisionName: { text: "半成品分类名" },
        combinationCD: { text: "配料编号" },
        combinationName: { text: "配料名" },
        combinationShortName: { text: "配料名简称" },
        combinationRomaName: { text: "配料名罗马字" },
        yield: { text: "保留" },
        baseWeight: { text: "基本重量" },
        vwDivision: { text: "V/W区分" },
        specificGravity: { text: "比重" },
        facilitiesCD: { text: "设备编号" },
        facilitiesName: { text: "设备名" },
        maxWeight: { text: "投放最大重量" },
        lineCode: { text: "生产线编号" },
        lineName: { text: "生产线名" },
        priority: { text: "优先顺序" },
        combinationID: { text: "序列号" },
        other: { text: "其它工厂" },
        recipe: { text: "明细" },
        UpateTimestamp: { text: "更新日期" }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        combinationCD: {
            rules: { required: true },
            messages: { required: "配料编号为必须输入内容。" }
        },
        combinationName: {
            rules: { required: true },
            messages: { required: "配料名为必须输入内容。" }
        },
        yield: {
            rules: { digits: true },
            messages: { digits: "保留的输入只是数值" }
        },
        categoryName: {
            rules: { required: true },
            messages: { required: "分类名为必须输入内容。" }
        },
        articleDivisionName: {
            rules: { required: true },
            messages: { required: "半成品分类名为必须输入内容。" }
        },
        facilitiesName: {
            rules: { required: true },
            messages: { required: "设备名为必须输入内容。" }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
    // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
    // TODO: ここまで
});
})();
