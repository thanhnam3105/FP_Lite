(function () {
    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "厂商主表一览" },

        kbn_torihiki: { text: "厂商区分" },
        nm_kbn_torihiki: { text: "厂商区分" },
        nm_torihiki: { text: "厂商名称" },
        cd_torihiki: { text: "厂商编号" },
        nm_torihiki_ryaku: { text: "厂商简称" },
        nm_busho: { text: "部门名" },
        no_yubin: { text: "邮政编号" },
        nm_jusho: { text: "住址" },
        no_tel: { text: "ＴＥＬ" },
        no_fax: { text: "传真" },
        e_mail: { text: "Ｅ－Ｍａｉｌ" },
        nm_tanto_1: { text: "担当者（１）" },
        nm_tanto_2: { text: "担当者（２）" },
        nm_tanto_3: { text: "担当者（３）" },
        kbn_keishiki_nonyusho: { text: "入库单形式" },
        nm_kbn_keishiki_nonyusho: { text: "入库单形式" },
        kbn_keisho_nonyusho: { text: "敬称区分" },
        nm_kbn_keisho_nonyusho: { text: "敬称区分" },
        kbn_hin: { text: "品区分" },
        biko: { text: "备注" },
        cd_maker: { text: "制造商编号" },
        flg_pikking: { text: "检选标志" },
        flg_mishiyo: { text: "未使用" },
        display_unused: { text: "未使用显示" },
        dt_create: { text: "登录日" },
        cd_create: { text: "登录者编号" },
        dt_update: { text: "更新日" },
        cd_update: { text: "更新者编号" },
        ts: { text: "时间标记" },
        nonyusho: { text: "入库单形式" },
        notUse: { text: "不使用时" },
        nm_keishiki_nonyu: { text: "入库数量" },
        nm_keishiki_shiyou: { text: "使用数量" },
        nm_keisho_sama: { text: "先生" },
        nm_keisho_onchu: { text: "殿" },
        nm_keisho_nashi: { text: "无" },
        nm_flg_mishiyo_ari: { text: "有" },
        nm_flg_mishiyo_nashi: { text: "无" },
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

        //要らないものをカットしていく 影居
        combDetail: { text: "配料详细" },
        categoryCode: { text: "分类编号" },
        categoryName: { text: "分类名" },
        articleDivisionCD: { text: "半成品分类编号" },
        articleDivisionName: { text: "半成品分类名" },
        combinationCD: { text: "配料编号" },
        combinationName: { text: "配料名" },
        combinationShortName: { text: "配料简称" },
        combinationRomaName: { text: "配料名罗马字" },
        yield: { text: "保留" },
        baseWeight: { text: "基本重量" },
        vwDivision: { text: "V/W区分" },
        specificGravity: { text: "比重" },
        facilitiesCD: { text: "设备编号" },
        facilitiesName: { text: "设备名" },
        maxWeight: { text: "投放最大重" },
        lineCode: { text: "生产线编号" },
        lineName: { text: "生产线名" },
        priority: { text: "优先顺序" },
        combinationID: { text: "序列号" },
        other: { text: "其它工厂" },
        recipe: { text: "明细" },
        UpateTimestamp: { text: "更新日期" }
        // ここまで

    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_torihiki: {
            rules: {
                required: "厂商编号",
                alphanum: true,
                maxbytelength: 13
            },
            params: {
                custom: "厂商编号"
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
                required: "厂商名称",
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
    App.ui.pagedata.validation2("zh", {
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
    App.ui.pagedata.operation("zh", {
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
