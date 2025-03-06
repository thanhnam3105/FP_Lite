(function () {

    App.ui.pagedata.lang("vi", {
        masterKubunId: { data: [{ id: "1", name: "Master nguyên vật liệu" }, { id: "2", name: "Master công thức" }] }
        , jotaiKubunId: { data: [{ id: "1", name: "Dạng bột" }, { id: "2", name: "Dạng lỏng" }, { id: "3", name: "Sản phẩm R&D" }, { id: "9", name: "Khác" }] }
        , hokanKubunId: { data: [{ id: "1", name: "Kho thường" }, { id: "2", name: "Kho mát " }, { id: "3", name: "Kho đông lạnh" }] }
        , yobiId: { data: [{ id: "0", name: "Chủ nhật", shortName: "CN" }, { id: "1", name: "Thứ 2", shortName: "T2" }, { id: "2", name: "Thứ 3", shortName: "T3" }, { id: "3", name: "Thứ 4", shortName: "T4" }, { id: "4", name: "Thứ 5", shortName: "T5" }, { id: "5", name: "Thứ 6", shortName: "T6" }, { id: "6", name: "Thứ 7", shortName: "T7" }] }
        , yobiHidukeId: { data: [{ id: "0", name: "{0}(CN)" }, { id: "1", name: "{0}(T2)" }, { id: "2", name: "{0}(T3)" }, { id: "3", name: "{0}(T4)" }, { id: "4", name: "{0}(T5)" }, { id: "5", name: "{0}(T6)" }, { id: "6", name: "{0}(T7)" }] }
        , kuraireId: { data: [{ id: "1", name: "Nhập kho ngay" }, { id: "2", name: "Chưa đóng gói" }, { id: "3", name: "Không nhập kho" }] }
        , nonyushoId: { data: [{ id: "0", name: "" }, { id: 1, name: "Số lượng mua hàng" }, { id: 2, name: "Số lượng sử dụng" }] }
        , kanzanKubunId: { data: [{ id: "4", name: "Kg" }, { id: "11", name: "L" }] }
        , gassanKubunId: { data: [{ id: "0", name: "Không gộp" }, { id: "1", name: "Tính gộp" }] }
        //, kengenKubunId: { data: [{ id: "Admin", name: "Administrator" }, { id: "Editor", name: "Editor" }, { id: "Operator", name: "Operator" }, { id: "Viewer", name: "Viewer"}] }
        , kengenKubunId: { data: [{ id: "Admin", name: "Quản lý" }, { id: "Manufacture", name: "Bộ phận sản xuất" }, { id: "Purchase", name: "Bộ phận thu mua" }, { id: "Quality", name: "Bộ phận quản lý chất lượng" }, { id: "Warehouse", name: "Bộ phận kho" }] }
        , monthNameId: { data: [{ id: 0, name: "Tháng 1", shortName: "Tháng 1" }, { id: 1, name: "Tháng 2", shortName: "Tháng 2" }, { id: 2, name: "Tháng 3", shortName: "Tháng 3" }, { id: 3, name: "Tháng 4", shortName: "Tháng 4" }, { id: 4, name: "Tháng 5", shortName: "Tháng 5" }, { id: 5, name: "Tháng 6", shortName: "Tháng 6" }, { id: 6, name: "Tháng 7", shortName: "Tháng 7" }, { id: 7, name: "Tháng 8", shortName: "Tháng 8" }, { id: 8, name: "Tháng 9", shortName: "Tháng 9" }, { id: 9, name: "Tháng 10", shortName: "Tháng 10" }, { id: 10, name: "Tháng 11", shortName: "Tháng 11" }, { id: 11, name: "Tháng 12", shortName: "Tháng 12" }] }
        , tenkaiKubunId: { data: [{ id: 0, name: "Không" }, { id: 1, name: "Có" }] }
        , riyuBunruiKubunId: { data: [{ id: 1, name: "Lý do điều chỉnh" }, { id: 2, name: "Lý do ngày nghỉ" }] }
        , dateFormatId: { data: [{ id: 0, number: 2 }, { id: 1, number: 2 }, { id: 2, number: 4}] }
        , nyukoKunbunId: { data: [{ id: 1, name: "Có phí" }, { id: 7, name: "Miễn phí"}] }
        , densoKunbunId: { data: [{ id: 1, name: "Tạo mới" }, { id: 2, name: "Cập nhật" }, { id: 3, name: "Xóa"}] }
        // ■仕掛残計上機能OFF対応(機能ONは下のコメントアウトをオープンして下さい):リストボックスから削除
        , anbunKubunId: { data: [{ id: 1, name: "Sản xuất" }, { id: 2, name: "Điều chỉnh" }/*, { id: 3, name: "Process inventory"}*/] }
        , densoJotaiId: { data: [{ id: 0, name: "Chưa tạo" }, { id: 1, name: "Chưa gửi" }, { id: 2, name: "Chờ gửi" }, { id: 3, name: "Đang gửi" }, { id: 4, name: "Đã gửi"}] }
        , torokuJotaiId: { data: [{ id: 0, name: "Chưa đăng ký" }, { id: 1, name: "Đang chờ" }, { id: 2, name: "Đã đăng ký" }] }
        // 最終行はカンマ不要
        //---------------------------------------------------------
        //2019/07/23 trinh.bd Task #14029
        //------------------------START----------------------------
        , roleNewId: { data: [{ id: 0, name: "" }, { id: 1, name: "Chỉ xem" }, { id: 2, name: "Chỉnh sửa" }] }
        //-------------------------END-----------------------------
    });

})();