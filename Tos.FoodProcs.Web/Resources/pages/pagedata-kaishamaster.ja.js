(function () {
    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "会社マスタ" },
        cd_kaisha: { text: "会社コード" },
        nm_kaisha: { text: "会社名称" },
        nm_kaisha_ryaku: { text: "会社略称" },
        nm_jusho: { text: "住所" },
        no_tel_1: { text: "TEL1" },
        no_tel_2: { text: "TEL2" },
        no_fax_1: { text: "FAX1" },
        no_fax_2: { text: "FAX2" },
        dt_create: { text: "登録日" },
        dt_update: { text: "更新日" },
        saveConfirm: { text: MS0064 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        unloadWithoutSave: { text: MS0066 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        nm_kaisha: {
            rules: {
                illegalchara: true,
                maxbytelength: 50
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        no_yubin: {
            rules: {
                haneisukigo: true,
                //postnum: true,
                maxbytelength: 10
                
            },
            messages: {
                maxbytelength: MS0012,
                haneisukigo: MS0439
            }
        },
        nm_jusho_1: {
            rules: {
                illegalchara: true,
                maxbytelength: 30
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        nm_jusho_2: {
            rules: {
                illegalchara: true,
                maxbytelength: 30
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        nm_jusho_3: {
            rules: {
                illegalchara: true,
                maxbytelength: 30
            },
            messages: {
                illegalchara: MS0005,
                maxbytelength: MS0012
            }
        },
        no_tel_1: {
            rules: {
                haneisukigo: true,
                //telnum: true,
                maxbytelength: 20
            },
            messages: {
                maxbytelength: MS0012,
                haneisukigo: MS0439
            }
        },
        no_tel_2: {
            rules: {
                haneisukigo: true,
                //telnum: true,
                maxbytelength: 20
            },
            messages: {
                maxbytelength: MS0012,
                haneisukigo: MS0439
            }
        },
        no_fax_1: {
            rules: {
                haneisukigo: true,
                //faxnum: true,
                maxbytelength: 20
            },
            messages: {
                maxbytelength: MS0012,
                haneisukigo: MS0439      

            }
        },
        no_fax_2: {
            rules: {
                haneisukigo: true,
                //faxnum: true,         
                maxbytelength: 20
            },
            messages: {
                maxbytelength: MS0012,
                haneisukigo: MS0439         
            }
        },
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Purchase: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });
})();
