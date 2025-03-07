(function () {
    var lang = App.ui.pagedata.lang("vi", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "Master công thức" },
        cd_bunrui: { text: "Mã nhóm bán thành phẩm" },
        nm_bunrui: { text: "Phân loại nhóm"},
        cd_haigo: { text: "Mã công thức" },
        nm_haigo: { text: "Tên công thức" },
        nm_haigo_ryaku: { text: "Tên công thức (viết tắt)" },
        ritsu_budomari: { text: "Tỉ lệ<br>sử dụng" },
        ritsu_kihon: { text: "Bội suất cơ bản" },
        wt_kihon: { text: "Trọng lượng cơ bản" },
        kbn_kanzan: { text: "Đơn vị<br>quy đổi" },
        ritsu_hiju: { text: "Tỉ trọng" },
        flg_gassan_shikomi: { text: "Tính gộp<br>lượng sản xuất" },
        shikomi_gassan: { text: "Tính gộp lượng sản xuất" },
        wt_saidai_shikomi: { text: "Trọng lượng sản xuất tối đa" },
        flg_shorihin: { text: "Nhãn BTP" },    // Processing<br>product (2014.09.03)処理品 → 調味液
        flg_mishiyo_item: { text: "Không<br>sử dụng" },
        cd_line: { text: "Mã dây chuyền" },
        nm_line: { text: "Tên dây chuyền" },
        no_yusen: { text: "Thứ tự<br>ưu tiên" },
        flg_tenkai: { text: "Tự động<br>lên kế hoạch" },
        mishiyo: { text: "Phạm vi hiển thị"},
        flg_shiyo: { text: "Toàn bộ" },
        flg_mishiyo: { text: "Chỉ dữ liệu đang sử dụng" },
        ts: { text: "Timestamp" },
        lineSave: { text: "Đăng ký dây chuyền" },
        no_han: { text: "Phiên bản" },
        dt_from: { text: "Thời hạn hiệu lực" },
        dt_from_meisai: { text: "Ngày hiệu lực (bắt đầu)" },
        dt_from_criteria: { text: "Ngày hiệu lực" },
        notUse: { text: "Trường hợp không sử dụng"},
        dt_create: { text: "Ngày đăng ký" },
        dt_update: { text: "Ngày cập nhật" },
        delHaigo: { text: "Xóa công thức" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        notFound: { text: MS0037 },
        noRecords: { text: MS0442 },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        each_lang_width: { number: 180 },
        cd_haigo_width: { number: 120 },
        nm_haigo_width: { number: 320 },
        nm_haigo_ryaku_width: { number: 180 },
        nm_bunrui_width: { number: 190 },
        ritsu_budomari_width: { number: 60 },
        ritsu_kihon_width: { number: 120 },
        kbn_kanzan_width: { number: 80 },
        ritsu_hiju_width: { number: 80 },
        flg_gassan_shikomi_width: { number: 100 },
        wt_saidai_shikomi_width: { number: 130 },
        flg_shorihin_width: { number: 100 },
        cd_line_width: { number: 95 },
        nm_line_width: { number: 160 },
        no_juni_yusen_width: { number: 80 },
        flg_tenkai_width: { number: 110 },
        flg_mishiyo_width: { number: 70 },
        no_han_width: { number: 65 },
        dt_from_width: { number: 80 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        nm_haigo: {
            rules: {
                maxbytelength: 50
            },
            messages: {
                maxbytelength: MS0012
            }
        },
        dt_from: {
            rules: {
                required: "Ngày hiệu lực",
                maxbytelength: 10,
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(3000, 12 - 1, 31 + 1)
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            NotRole: { visible: false }
        },
        colchange: {
            NotRole: { visible: false }
        },
        add: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        detail: {
            NotRole: { visible: false }
        },
        copy: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        excel: {
            NotRole: { visible: false }
        },
        del: {
            NotRole: { visible: false },
            isRoleFisrt: { visible: false }
        },
        recipe: {
            NotRole: { visible: false }
        },
        shikakari: {
            NotRole: { visible: false }
        },
        line: {
            NotRole: { visible: false }
        }
        // TODO: ここまで
    });
})();