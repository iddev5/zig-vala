class TestApp : Gtk.Application {
    public TestApp() {
        GLib.Object(application_id: "org.iddev.testapp");
    }

    public override void activate() {
        var window = new Gtk.Window();
        window.title = "test app";
        window.window_position = Gtk.WindowPosition.CENTER;
        window.set_default_size(800, 600);

        this.add_window(window);

        window.show_all();
    }
}

int main(string[] args) {
    var app = new TestApp();
    return app.run(args);
}
