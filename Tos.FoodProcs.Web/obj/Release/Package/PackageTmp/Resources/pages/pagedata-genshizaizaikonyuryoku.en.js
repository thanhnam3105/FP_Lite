(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Input Material Inventory" },
        // 検索条件
        dt_zaiko: { text: "Date" },
        shiyoubun: { text: "Used" },
        mishiyoubun: { text: "Unused" },
        ari_nomi: { text: "Inventory exist only" },
        hinKubun: { text: "Item type" },
        hinBunrui: { text: "Group" },
        kurabasho: { text: "Issued location" },
        hinmei: { text: "Item name" },
        ryohin: { text: "Good product" },
        horyu: { text: "Defer" },
        soko: { text: "Warehouse" },
        // 明細
        flg_kakutei: { text: "Confirm" },
        cd_hinmei: { text: "Code" },
        nm_hinmei: { text: "Name" },
        nm_nisugata: { text: "Packing style" },
        tani_nonyu: { text: "Delivery<br>unit" },
        tani_shiyo: { text: "Usage<br>unit" },
        keisan_zaiko: { text: "Calculate inventory<br>quantity (usage unit)" },
        jitsuzaiko_nonyu: { text: "Actual inventory<br>quantities (delivery unit)" },
        jitsuzaiko_hasu: { text: "Actual inventory<br>fraction quantities (delivery unit)" },
        su_zaiko: { text: "Actual inventory<br>quantities (usage unit)" },
        dt_kakutei_zaiko: { text: "Actual inventory<br>confirm date" },
        flg_mishiyo: { text: "Unused" },
        tan_tana: { text: "Unit price" },
        kingaku: { text: "Amount" },
        totalKingaku: { text: "Total amount" },
        sokoName: { text: "Warehouse<br>name" },
        sokoCode: { text: "Warehouse code" },
        copyKeisanZaiko: { text: "Copy calculate inventory" },
        zaikoCopy: { text: "Copy Inventory" },
        //retrasmitInventory: { text: "Retrasmit Inventory" },
        retrasmitInventory: { text: "Transmit Inventory" },
        // 隠し項目
        wt_ko: { text: "Weight of piece" },
        su_iri: { text: "Contained number" },
        nm_hinkbn: { text: "Item type(hide)" },
        cd_tani_nonyu: { text: "Delivery unit code" },
        cd_kura: { text: "Warehouse location code" },
        nm_kura: { text: "Warehouse location name" },
        //BRC quang.l 2022/04/21 #1699 Start -->
        dt_update: { text: "Update date" },
        //BRC quang.l 2022/04/21 #1699 Start <--
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        searchConfirm: { text: MS0065 },
        excelChangeMeisai: { text: MS0560 },
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 },
        changeCondition: { text: MS0299 },
        limitOver: { text: MS0011 },
        checkboxCondition: { text: MS0177 },
        successExcel: { text: MS0111 },
        endCopy: { text: MS0040 },
        zaikocopyConfirm: { text: MS0764 },
        zaikocopyChangeMeisai: { text: MS0765 },
        //retrasmitInventoryConfirm: { text: MS0788 },
        trasmitInventoryConfirm: { text: MS0804 },
        noDataRetrasmit: { text: MS0787 },
        //retrasmittingCompletion: { text: MS0789 },
        trasmittingCompletion: { text: MS0805 },
        trasmittingError: { text: MS0749 },
        // TODO: ここまで
        // TODO: 伝送処理の確認
        id_jobnet: { text: "GETSUMATSU_ZAIKO"},
        flg_shori: { text: "1"},
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        nm_soko_width: { number: 100 },
        nm_bunrui_width: { number: 120 },
        cd_hinmei_width: { number: 80 },
        nm_hinmei_width: { number: 180 },
        nm_nisugata_hyoji_width: { number: 100 },
        tani_nonyu_width: { number: 60 },
        tani_shiyo_width: { number: 60 },
        su_keisan_zaiko_width: { number: 180 },
        jitsuzaiko_nonyu_width: { number: 180 },
        jitsuzaiko_hasu_width: { number: 180 },
        su_zaiko_width: { number: 180 },
        dt_jisseki_zaiko_width: { number: 180 },
        tan_ko_width: { number: 90 },
        kingaku_width: { number: 110 },
        flg_mishiyo_width: { number: 80 },
        //each_lang_width: { number: 130 },
        each_lang_width: { number: 120 },
        ari_nomi_width: { number: 195 },

        // 在庫伝送用パラメータ
        kbnCreate: { number: 1 },
        kbnUpdate: { number: 2 },
        kbnDelete: { number: 3 },
        flg_true: { number: 1 },
        flg_false: { number: 0 },
        kbnGenryo: { number: 2 },
        kbnShizai: { number: 3 },
        kbnJikagen: { number: 7 },
        kbnZaiko: { number: 1 },

        // TODO: ここまで
    });
    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        jitsuzaiko_nonyu: {
            rules: {
                range: [0, 99999999.9]
            },
            messages: {
                //range: MS0009
                range: MS0450
            }
        },
        jitsuzaiko_hasu: {
            rules: {
                range: [0, 99999999.9]
            },
            messages: {
                //range: MS0009
                range: MS0450
            }
        },
        su_zaiko: {
            rules: {
                //range: [0, 99999999.999999]
                range: [0, 99999999.999]
            },
            messages: {
                //range: MS0009
                range: MS0450
            }
        },
        //BRC t.Sato 2021/03/10 Start -->
        tan_tana: {
            rules: {
                range: [0, 99999999]
            },
            messages: {
                range: MS0450
            }
        },
        //BRC t.Sato 2021/03/10 End <--
        // 検索条件
        dt_zaiko: {
            rules: {
                required: "Inventory date",
                datestring: true,
                lessdate: new Date(1970, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0004,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        hinmei: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        colchange: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        save: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        excel: {
            Manufacture: { visible: true },
            Quality: { visible: true },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        csvUpload: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        zaikoCopy: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        },
        retrasmitInventory: {
            Manufacture: { visible: true },
            Quality: { visible: false },
            Purchase: { visible: true },
            Warehouse: { visible: true }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
