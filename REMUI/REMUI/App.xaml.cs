using REMUI.Pages;
using System;
using Xamarin.Forms;
using Xamarin.Forms.Xaml;

namespace REMUI
{
    public partial class App : Application
    {
        public App()
        {
            InitializeComponent();

            MainPage = new Orders();
        }

        protected override void OnStart()
        {
        }

        protected override void OnSleep()
        {
        }

        protected override void OnResume()
        {
        }
    }
}
