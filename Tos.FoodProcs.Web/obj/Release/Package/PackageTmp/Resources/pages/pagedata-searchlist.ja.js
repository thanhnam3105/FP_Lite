(function () {
    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "ID0003:配合マスタ一覧" },
        combDetail: { text: "配合詳細" },
        categoryCode: { text: "分類コード" },
        categoryName: { text: "分類名" },
        articleDivisionCD: { text: "仕掛品分類コード" },
        articleDivisionName: { text: "仕掛品分類名" },
        combinationCD: { text: "配合コード" },
        combinationName: { text: "配合名" },
        combinationShortName: { text: "配合名略" },
        combinationRomaName: { text: "配合名ローマ字" },
        yield: { text: "保留" },
        baseWeight: { text: "基本重量" },
        vwDivision: { text: "V/W区分" },
        specificGravity: { text: "比重" },
        facilitiesCD: { text: "設備コード" },
        facilitiesName: { text: "設備名" },
        maxWeight: { text: "仕込最大重" },
        lineCode: { text: "ラインコード" },
        lineName: { text: "ライン名" },
        priority: { text: "優先順" },
        combinationID: { text: "シーケンス番号" },
        other: { text: "他工場" },
        recipe: { text: "レシピ" },
        UpateTimestamp: { text: "更新日付" }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        combinationCD: {
            rules: { required: true },
            messages: { required: "配合コードは必須です。" }
        },
        combinationName: {
            rules: { required: true },
            messages: { required: "配合名は必須です。" }
        },
        yield: { 
            rules: { digits: true },
	        messages: { digits: "保留 は数値のみです" }
	    },
        categoryName: { 
            rules: { required: true },
            messages: { required: "分類名は必須です。" }
        },
        articleDivisionName: { 
            rules: { required: true },
            messages: { required: "仕掛品分類名は必須です。" }
        },
        facilitiesName: { 
            rules: { required: true },
            messages: { required: "設備名は必須です。" }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        // TODO: ここまで
    });
})();
