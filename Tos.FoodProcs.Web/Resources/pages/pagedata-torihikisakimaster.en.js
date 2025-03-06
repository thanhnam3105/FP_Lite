(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Vendor Master" },

        kbn_torihiki: { text: "Vendor type" },
        nm_kbn_torihiki: { text: "Vendor<br>type" },
        nm_torihiki: { text: "Name" },
        cd_torihiki: { text: "Code" },
        nm_torihiki_ryaku: { text: "Short name" },
        nm_busho: { text: "Department name" },
        no_yubin: { text: "ZIP code" },
        nm_jusho: { text: "Address" },
        no_tel: { text: "TEL" },
        no_fax: { text: "FAX" },
        e_mail: { text: "E-Mail" },
        nm_tanto_1: { text: "PIC (1)" },
        nm_tanto_2: { text: "PIC (2)" },
        nm_tanto_3: { text: "PIC (3)" },
        kbn_keishiki_nonyusho: { text: "Delivery paper type" },
        nm_kbn_keishiki_nonyusho: { text: "Delivery<br>paper type" },
        kbn_keisho_nonyusho: { text: "Title type" },
        nm_kbn_keisho_nonyusho: { text: "Title<br>type" },
        kbn_hin: { text: "Item type" },
        biko: { text: "Notes" },
        cd_maker: { text: "Maker code" },
        flg_pikking: { text: "Picking flag" },
        flg_mishiyo: { text: "Unused" },
        display_unused: { text: "Display unused" },
        dt_create: { text: "Registration date" },
        cd_create: { text: "Registrant code" },
        dt_update: { text: "Update date" },
        cd_update: { text: "Updater code" },
        ts: { text: "Time stamp" },
        nonyusho: { text: "Delivery paper type" },
        notUse: { text: "When not usage" },
        nm_keishiki_nonyu: { text: "Delivery amount" },
        nm_keishiki_shiyou: { text: "Usage amount" },
        nm_keisho_sama: { text: "Mr./Ms." },
        nm_keisho_onchu: { text: "Messrs" },
        nm_keisho_nashi: { text: "None" },
        nm_flg_mishiyo_ari: { text: "Yes" },
        nm_flg_mishiyo_nashi: { text: "No" },
        deleteConfirm: { text: MS0068 },
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        clearConfirm: { text: MS0070 },
        unloadWithoutSave: { text: MS0066 },
        saveConfirm: { text: MS0064 },
        saveComplete: { text: MS0036 },
        deleteComplete: { text: MS0039 },
        changeCriteria: { text: MS0299 },
        // TODO: ここまで

        //要らないものをカットしていく
        combDetail: { text: "Formula detail" },
        categoryCode: { text: "Group code" },
        categoryName: { text: "Group name" },
        articleDivisionCD: { text: "Progressing product group code" },
        articleDivisionName: { text: "Progressing product group name" },
        combinationCD: { text: "Formula code" },
        combinationName: { text: "Formula name" },
        combinationShortName: { text: "Short name of formula name" },
        combinationRomaName: { text: "Formula name in alphabet" },
        yield: { text: "Defer" },
        baseWeight: { text: "Basic weight" },
        vwDivision: { text: "V/W type" },
        specificGravity: { text: "Gravity" },
        facilitiesCD: { text: "Equipment code" },
        facilitiesName: { text: "Equipment name" },
        maxWeight: { text: "Maximum weight of produce" },
        lineCode: { text: "Line code" },
        lineName: { text: "Line name" },
        priority: { text: "Order of priority" },
        combinationID: { text: "Sequence number" },
        other: { text: "Other plant" },
        recipe: { text: "Recipe" },
        UpateTimestamp: { text: "Update date" }
        // ここまで

    });

    App.ui.pagedata.validation("en", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_torihiki: {
            rules: {
                required: "Vendor code",
                alphanum: true,
                maxbytelength: 13
            },
            params: {
                custom: "Vendor code"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0045
            }
        },
        
        nm_torihiki: {
            rules: {
                required: "Vendor name",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        nm_busho: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_torihiki_ryaku: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_tanto_1: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_tanto_2: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        nm_tanto_3: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        no_yubin: {
            rules: {
                haneisukigo: true,
                maxbytelength: 10
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        nm_jusho: {
            rules: {
                maxbytelength: 100
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        no_tel: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        no_fax: {
            rules: {
                haneisukigo: true,
                maxbytelength: 20
            },
            messages: {
                haneisukigo: MS0439,
                maxbytelength: MS0012
            }
        },
        cd_maker: {
            rules: {
                alphanum: true,
                maxbytelength: 13
            },
            messages: {
                alphanum: MS0439,
                maxbytelength: MS0012
            }
        },
        e_mail: {
            rules: {
                passwordilligalchar: true,
                maxbytelength: 256
            },
            messages: {
                passwordilligalchar: MS0005,
                maxbytelength: MS0012
            }
        },
        biko: {
            rules: {
                maxbytelength: 256
            },
            messages: {
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });
    App.ui.pagedata.validation2("en", {
        //TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        con_nm_torihiki: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("en", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("en", {
        search: {
            Manufacture: { visible: false }
        },
        colchange: {
            Manufacture: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        detail: {
            Manufacture: { visible: false }
        },
        copy: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Manufacture: { visible: false }
        },
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        clear: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }

    });

})();
