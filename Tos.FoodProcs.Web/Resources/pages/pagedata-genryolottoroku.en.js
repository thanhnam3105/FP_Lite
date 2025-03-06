(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Input Material Use Result" },        

        // 検索条件
        dt_hiduke_search: { text: "Date" },
        no_lot_search: { text: "Lot No." },
        cd_hinmei_search: { text: "Item name code" },

        // 結果一覧
        genryoLotSentakuButton: { text: "Input raw material lot" },
        genryoLotTorikeshiButton: { text: "Cancel use lot" },

        cd_hinmei: { text: "Raw material code", number: 155 },
        nm_hinmei_ryaku: { text: "Raw material name", number: 170 },
        nm_nisugata_hyoji: { text: "Packing style", number: 185 },
        nm_tani_shiyo: { text: "Usage unit", number: 80 },
        no_lot: { text: "Raw material lot No.", number: 225 },
        flg_henko: { text: "Change", number: 50 },
        no_kotei: { text: "Process", number: 50 },
        //no_tonyu: { text: "Putting order", number: 60 },
        //no_tonyu: { text: "Order", number: 60 },
        no_tonyu: { text: "Recipe order", number: 60 },
        biko: { text: "Comments", number: 200 },
        blank: { text: "", number: 0 },
        contentConfirm: { text: MS0784 }
    });

    App.ui.pagedata.validation("en", {
        cd_hinmei: {
            rules: {
                maxlength: 14,
            },
            params: {
            },
            messages: {
                maxlength: MS0012,
                custom: MS0786
            }
        },
        no_lot: {
            rules: {
            },
            params:{
            },
            messages:{
                custom: MS0785
            }
        },
        biko: {
            rules: {
                maxbytelength: 100
            },
            params: {
            },
            messages: {
                maxbytelength: MS0012
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },        
        colchange: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        genryoLotSentaku: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        genryoLotTorikeshi:{
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });
})();
