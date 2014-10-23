using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SharedResources.Common
{
    public static class Validator
    {
        public static void NotIsNullOrEmpty(string parm,string data, string message)
        {
            if(string.IsNullOrEmpty(data))
                throw new ArgumentException(message,parm);
        }
        public static void NotIsNullOrEmpty(string parm, Guid data, string message)
        {
            if (data == Guid.Empty)
                throw new ArgumentException(message, parm);
        }
        public static void NotIsNullOrWhitespace(string parm, string data, string message)
        {
            if (string.IsNullOrWhiteSpace(data))
                throw new ArgumentException(message, parm);
        }
        public static void NotNull(string parm, object data, string message)
        {
            if (data == null)
                throw new ArgumentException(message, parm);
        }
        public static void GreaterThanZero(string parm, int data, string message)
        {
            if (data <=0)
                throw new ArgumentException(message, parm);
        }
        public static void GreaterThanZero(string parm, double data, string message)
        {
            if (data <= 0)
                throw new ArgumentException(message, parm);
        }
        public static void HasValue(string parm, DateTime? data, string message)
        {
            if(!data.HasValue)
                throw new ArgumentException(message, parm);
        }
        public static void HasValue(string parm, Guid? data, string message)
        {
            if (!data.HasValue)
                throw new ArgumentException(message, parm);
        }
        public static void HasValue(string parm, int? data, string message)
        {
            if (!data.HasValue)
                throw new ArgumentException(message, parm);
        }
        public static void HasValue(string parm, bool? data, string message)
        {
            if (!data.HasValue)
                throw new ArgumentException(message, parm);
        }
       
    }
}
