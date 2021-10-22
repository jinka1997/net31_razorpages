using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SampleWeb.Models;

namespace SampleWeb.Data
{
    public class SampleWebContext : DbContext
    {
        public SampleWebContext (DbContextOptions<SampleWebContext> options)
            : base(options)
        {
        }

        public DbSet<SampleWeb.Models.Movie> Movie { get; set; }
    }
}
