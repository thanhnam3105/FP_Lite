using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.Entity;
using System.Data.Objects;
using Tos.FoodProcs.Web.Logging;
using System.Text;


namespace Tos.FoodProcs.Web.Data
{
    /// <summary>
    /// エンティティの変更セットを、監査ログに出力します
    /// </summary>
    public partial class FoodProcsEntities: ObjectContext
    {
        
        public override int SaveChanges(SaveOptions options)
        {
            // Object内の変更行数分処理を行う
            foreach (ObjectStateEntry entry in ObjectStateManager.GetObjectStateEntries(
            EntityState.Added | EntityState.Modified | EntityState.Deleted))
            {
                // 追加、修正があった場合、現在の値を出力する
                StringBuilder builder = new StringBuilder();

                System.Data.Common.DbDataRecord values = null;
                if (entry.State == EntityState.Deleted)
                {
                    values = entry.OriginalValues;
                }
                else
                {
                    values = entry.CurrentValues;
                }
                
                // entry内の列分処理を行う
                for (int i = 0; i < values.FieldCount; i++)
                {
                    builder.Append(values.GetName(i));
                    builder.Append(": [");
                    builder.Append(values.GetValue(i));
                    builder.Append("] ");
                }

                // 操作を行っているEntity名を出力
                builder.Append(entry.EntityKey.EntitySetName);
                builder.Append(" ");
                // 変更状態（追加か修正）を出力
                builder.Append(entry.State);
                builder.Append(" ");
                // 操作を行っているユーザIDを出力
                builder.Append(HttpContext.Current.User.Identity.Name);
                builder.Append(" ");
                // 操作を行っている時間を出力
                builder.Append(DateTime.UtcNow);
                // ログに内容を出力する
                Logger.Audit.Info(builder.ToString(), null);
                
            }

            return base.SaveChanges(options);
        }

    }
}