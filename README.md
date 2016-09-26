# [Sentosa AutoForms](http://learningmason.wordpress.com/)

Sentosa AutoForms aims to provide a web interface for databases, with forms, subforms, tables and reports, etc.
It is written in Perl and [Mason](http://www.masonhq.com).

![Sentosa Demo](https://raw.githubusercontent.com/fthiella/Sentosa/518976bc23023f955fc537ad48dfd325e01af40f/Sentosa.gif)

## Getting Started

Even if still in developement and with some features missing, I'm using Sentosa within my team and within my company already. This is how to prepare the server.

You will need perl:

    yum install perl

Also make sure cpanminus is installed:

    yum install cpanminus

Install CPAN modules:

    cpanm --notest Poet
    cpanm DBD::SQLite
    cpanm Log::Log4perl
    cpanm Log::Any::Adapter::Log4perl
    cpanm Mason::Plugin::WithEncoding

Prepare the local db:

    bin/install_db

Run Poet in development mode:

    bin/run.pl

Open it inside your browser:

    http://localhost:5000

You can now login with user: admin, password: password or user: user, password: password

## Creator

[Federico Thiella on Stackoverflow](http://stackoverflow.com/users/833073/fthiella)

## License

I'm using this bootstrap admin template [SB Admin 2](http://startbootstrap.com/template-overviews/sb-admin-2/)

## My blog

I started this project because:

* I'm interested in databases
* I actually need a simple web interface for my databases. Other apps I tried didn't suit my needs.
* I find [Mason](http://www.masonhq.com) a great and powerful Perl-based templating system, and I want to learn how to use it better

I'm documenting the developement process here:
http://learningmason.wordpress.com

:)
