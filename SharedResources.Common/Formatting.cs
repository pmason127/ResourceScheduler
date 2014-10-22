using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace SharedResources.Common
{
    public static class Formatting
    {
        private static readonly Regex htmlRegex = new Regex(@"<[^>]+>|\&nbsp\;",RegexOptions.Multiline|RegexOptions.IgnoreCase|RegexOptions.Compiled);
        private static readonly Regex spaceRegex = new Regex(@"\s{2,}",RegexOptions.Compiled);
        private static readonly Regex scriptRegEx = new Regex("<script[^>]*(?<!/)>.*?</script>|<style[^>]*(?<!/)>.*?</style>", RegexOptions.Multiline  | RegexOptions.IgnoreCase | RegexOptions.Compiled);

        public static string RemoveHtml(this string input)
        {
            if (string.IsNullOrEmpty(input)) return string.Empty;
            string noScript = scriptRegEx.Replace(input, "");
            string noHtml = htmlRegex.Replace(noScript, "").Trim();
            string clean = spaceRegex.Replace(noHtml, "");
            return clean;

        }
    }
}
