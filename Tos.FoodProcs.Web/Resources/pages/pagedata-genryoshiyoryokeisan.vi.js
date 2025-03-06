(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("vi", {
        // 画面項目のテキスト
        //_pageTitle: { text: "Usage quantities of raw material calculation" },
        // 2014.11.10 名称変更：原料使用量計算→庫出依頼
        _pageTitle: { text: "Yêu cầu xuất kho" },
        // 明細
        dt_shukko: { text: "Ngày xuất kho" },
        cd_hinmei: { text: "Mã" },
        nm_hinmei: { text: "Tên" },
        nm_nisugata_hyoji: { text: "Quy cách đóng gói" },
        nm_tani: { text: "Đơn vị<br>sử dụng" },
        su_shiyo_sum: { text: "Số lượng dự định<br>sử dụng" },
        wt_shiyo_zan: { text: "Số lượng tồn<br>hôm trước" },
        qty_hitsuyo: { text: "Số lượng cần để SX<br>(Đơn vị sử dụng)" },
        su_kuradashi: { text: "Số lượng yêu cầu<br>xuất kho" },
        su_kuradashi_sum: { text: "Yêu cầu<br>xuất kho" },
        su_kuradashi_su: { text: "Số lượng" },
        su_kuradashi_hasu: { text: "Số lẻ" },
        flg_kakutei: { text: "Duyệt" },
        kbn_status: { text: "Trạng thái" },
        nm_bunrui: { text: "Phân loại nhóm" },
        dt_hiduke: { text: "Ngày đăng ký" },
        shukkobi: { text: "Đổi ngày xuất kho" },
        allCheck: { text: "Chọn Duyệt toàn bộ" },
        cd_tani_kuradashi: { text: "Đơn vị" },
        nm_tani_kuradashi: { text: "Đơn vị<br>xuất kho" },

        // 旧項目
        qty_hitsuyoNonyu: { text: "Lượng cần thiết<br>(Đơn vị nhập)" },
        qty_hitsuyoNonyuHasu: { text: "Lượng cần thiết (số lẻ)<br>(Đơn vị nhập)" },
        nm_torihiki_ryaku: { text: "Nhà cung cấp" },
        zan_hiduke: { text: "Ngày tồn" },

        // 検索条件
        dt_hiduke_search: { text: "Ngày sản xuất" },
        kbn_hin_search: { text: "Loại" },
        nm_jikagenryo: { text: "SP trung gian" },

        // 項目の幅
        flg_kakutei_width: { number: 100 },
        each_lang_width: { number: 100 },

        // 画面メッセージ
        searchConfirm: { text: MS0065 },
        saveConfirm: { text: MS0064 },
        clearConfirm: { text: MS0070 },
        noRecords: { text: MS0442 },
        notFound: { text: MS0037 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        criteriaChange: { text: MS0048 },
        unloadWithoutSave: { text: MS0066 },
        unprintableCheck: { text: MS0560 },
        limitOver: { text: MS0011 }
    });

    App.ui.pagedata.validation("vi", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        wt_shiyo_zan: {
            rules: {
                required: "Lượng tồn hôm trước",
                range: [0, 999999.999],
                number: true
            },
            messages: {
                required: MS0042,
                range: MS0450,
                number: MS0441
            }
        },
        su_kuradashi: {
            rules: {
                range: [0, 9999999],
                number: true
            },
            messages: {
                range: MS0450,
                number: MS0441
            }
        },
        su_kuradashi_hasu: {
            rules: {
                range: [0, 9999999],
                number: true
            },
            messages: {
                range: MS0450,
                number: MS0441
            }
        },
        dt_shukko: {
            rules: {
                required: "Ngày xuất kho",
                datestring: true
            },
            messages: {
                required: MS0042,
                datestring: MS0247
            }
        },
        // 検索条件
        dt_hiduke_search: {
            rules: {
                required: "Ngày",
                datestring: true
            },
            messages: {
                required: MS0004,
                datestring: MS0247
            }
        },
        // 検索条件
        dt_shukko_henko: {
            rules: {
                datestring: true
            },
            messages: {
                datestring: MS0247
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("vi", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colchange: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();