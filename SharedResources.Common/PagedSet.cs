using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;

namespace SharedResources.Common
{
    
    public class PagedList<T>:Collection<T>
    {
        public PagedList()
        {
            
        }
        public PagedList(IEnumerable<T> items, int pageIndex,int pageSize,int totalItems):base(items.ToList())
        {
            this.PageIndex = pageIndex;
            this.PageSize = pageSize;
            this.TotalItems = totalItems;

            this.TotalPages  = this.TotalItems/this.PageSize;
            if (this.TotalItems % this.PageSize > 0)
                this.TotalPages++;
        }

        public int PageIndex { get; private set; }
        public int PageSize { get; private set; }
        public int TotalItems { get; private set; }
        public int TotalPages { get; private set; }
        public bool IsFirstPage
        {
            get { return this.PageIndex == 1; }
        }
        public bool IsLastPage
        {
            get { return (this.PageIndex) >= this.TotalPages; }
        }
    }
}
