using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace SharedResources.Common
{
    public static class DataReaderExtensions
    {
        public static string GetStringColumn(this IDataReader reader,string columnName)
        {
            int ord = reader.GetOrdinal(columnName);
            return reader.GetString(ord);
        }
        public static string GetSafeStringColumn(this IDataReader reader, string columnName, string defaultValue)
        {
            int ord = reader.GetOrdinal(columnName);
            if(reader.IsDBNull(ord))
                return defaultValue;

            return reader.GetString(ord);
        }
        public static int GetInt32Column(this IDataReader reader, string columnName)
        {
            int ord = reader.GetOrdinal(columnName);
            return reader.GetInt32(ord);
        }
        public static int? GetSafeInt32Column(this IDataReader reader, string columnName, int? defaultValue)
        {
            int ord = reader.GetOrdinal(columnName);
            if (reader.IsDBNull(ord))
                return defaultValue;

            return reader.GetInt32(ord);
        }
        public static int GetInt16Column(this IDataReader reader, string columnName)
        {
            int ord = reader.GetOrdinal(columnName);
            return reader.GetInt16(ord);
        }
        public static int? GetSafeInt16Column(this IDataReader reader, string columnName, int? defaultValue)
        {
            int ord = reader.GetOrdinal(columnName);
            if (reader.IsDBNull(ord))
                return defaultValue;

            return reader.GetInt16(ord);
        }
        public static DateTime GetDateTimeColumn(this IDataReader reader, string columnName)
        {
            int ord = reader.GetOrdinal(columnName);
            return reader.GetDateTime(ord);
        }
        public static DateTime? GetSafeDateTimeColumn(this IDataReader reader, string columnName, DateTime? defaultValue)
        {
            int ord = reader.GetOrdinal(columnName);
            if (reader.IsDBNull(ord))
                return defaultValue;

            return reader.GetDateTime(ord);
        }
        public static bool GetBoolColumn(this IDataReader reader, string columnName)
        {
            int ord = reader.GetOrdinal(columnName);
            return reader.GetBoolean(ord);
        }
        public static bool? GetSafeBoolColumn(this IDataReader reader, string columnName, bool? defaultValue)
        {
            int ord = reader.GetOrdinal(columnName);
            if (reader.IsDBNull(ord))
                return defaultValue;

            return reader.GetBoolean(ord);
        }
        public static Guid GetGuidColumn(this IDataReader reader, string columnName)
        {
            int ord = reader.GetOrdinal(columnName);
            return reader.GetGuid(ord);
        }
        public static Guid? GetSafeGuidColumn(this IDataReader reader, string columnName, Guid? defaultValue)
        {
            int ord = reader.GetOrdinal(columnName);
            if (reader.IsDBNull(ord))
                return defaultValue;

            return reader.GetGuid(ord);
        }

        public static double? GetSafeDoubleColumn(this IDataReader reader, string columnName, double? defaultValue)
        {
            int ord = reader.GetOrdinal(columnName);
            if (reader.IsDBNull(ord))
                return defaultValue;

            return reader.GetDouble(ord);
        }
        public static double GetDoubleColumn(this IDataReader reader, string columnName)
        {
            int ord = reader.GetOrdinal(columnName);
            return reader.GetDouble(ord);
        }
    }
}
