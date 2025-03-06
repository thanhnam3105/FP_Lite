(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "担当者主表" },
        // 明細
        cd_tanto: { text: "编号" },
        nm_tanto: { text: "担当者名" },
        RoleName: { text: "权限" },
        mishiyoFlag: { text: "未使用" },
        blank: { text: "" },
        // 検索条件
        tantoshaNameSearchText: { text: "担当者" },
        roleNameSearch: { text: "权限" },
        searchConfirm: { text: MS0065 },
        // リテラル
        password: { text: "密码" },
        passwordConfirm: { text: "密码确认用" },
        passwordReset: { text: "密码清除" },
        kyoseiHoshinFlag: { text: "强制推进" },



        //旧権限
        editorText: { text: "编者" },
        operatorText: { text: "操作者" },
        viewerText: { text: "阅览者" },
        //新権限
        adminText: { text: "管理者" },
        manufactureText: { text: "生产担当者" },
        purchaseText: { text: "购买担当者" },
        qualityText: { text: "品质管理担当者" },
        //warehouseText: { text: "领货担当者" },
        warehouseText: { text: "入库担当者" },
        //---------------------------------------------------------
        //2019/07/23 trinh.bd Task #14029 No.3
        //------------------------START----------------------------
        kobetsuSetteiText: { text: "个别设定" },
        hinMeiText: { text: "品名主表" },
        haigoText: { text: "配料主表" },
        konyuText: { text: "原材料购买商主表" },
        shikakarihinText: { text: "半成品投入计划" },
        insatsuKinoText: { text: "打印功能" },
        //-------------------------END-----------------------------

        inputAnnounceText: { text: "请输入密码半角5文字以上" },
        inputAnnounce2Text: { text: "在个别设定中选择空白时，主表不会显示在画面上。" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        deleteConfirm: { text: MS0068 },
        showGridConfirm: { text: MS0072 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: {text: MS0560},
        diffCode: {text: MS0709},
        // TODO: ここまで
    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        tantoshaNameSearchText: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        cd_tanto: {
            rules: {
                required: "担当者编号",
                alphanum: true,
                maxbytelength: 10
                
                
            },
            params: {
                custom: "担当者编号"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxbytelength: MS0012,
                custom: MS0045
            }
        },
        nm_tanto: {
            rules: {
                required: "担当者名",
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        password: {
            rules: {
                required: "密码",
                maxbytelength: 128,
                minbytelength: 5,
                passwordilligalchar: true
            },
            messages: {
                required: MS0042,
                minbytelength: MS0571,
                maxbytelength: MS0012,
                passwordilligalchar: MS0005,
                custom: MS0574
            }
        },
        passwordConfirm: {
            rules: {
                required: "密码",
                maxbytelength: 128,
                minbytelength: 5,
                passwordilligalchar: true
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                minbytelength: MS0571,
                passwordilligalchar: MS0005,
                custom: MS0574
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            //Operator: { visible: false },
            //Editor: { visible: false },
            //Viewer: { visible: false }
        },
        colchange: {
            //Operator: { visible: false },
            //Editor: { visible: false },
            //Viewer: { visible: false }
        },
        add: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },        
        detail: {
            //Operator: { visible: false },
            //Editor: { visible: false },
            //Viewer: { visible: false }
        },
        del: {
            Manufacture: { visible: false },
            Purchase: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }

        // TODO: ここまで
    });

    //// ページデータ -- End
})();
