package Text::CGILike;

# ABSTRACT: Wrapper to create text file using the CGI syntax

use strict;
use warnings;
use Moo;
use Text::Format;

my $TF = Text::Format->new({firstIndent => 0, bodyIndent => 0});

# VERSION

our (@ISA, @EXPORT, %EXPORT_TAGS);

BEGIN {
    require Exporter;

    my @html2 = qw/start_html end_html h1/;

    @ISA = qw(Exporter);
    @EXPORT = (@html2);
    %EXPORT_TAGS = (
        'html2' => [@html2],
        'standard' => [@html2]
    );
}

my $CLASS_SINGLE;

has 'columns' => (
    is => 'ro',
    default => sub { 80 },
);

sub start_html { return "" }
sub end_html { return "" }

sub h1 {
    my ($self, $title) = _self_or_default(@_);
    return 
    $self->hr .
    $self->_center("# ", " #", $title) .
    $self->hr;
}

sub hr {
    my ($self) = _self_or_default(@_);

    return "#"x($self->columns)."\n";
}

### PRIVATE ###

sub _self_or_default {
    my ($may_class, @param) = @_;
    if (ref $may_class eq __PACKAGE__) {
        return ($may_class, @param);
    } else {
        $CLASS_SINGLE ||= __PACKAGE__->new;
        return ($CLASS_SINGLE, $may_class, @param);
    }
}

sub _center {
    my $self = shift;
    my ($left, $right, $text) = @_;
    $left = "" unless defined $left;
    $right = "" unless defined $right;

    my $size = $self->columns - length($left) - length($right);
    $TF->columns($size);
    my @texts = $TF->format($text);
    return join("\n", map {
        $_ = $TF->center($_);
        chomp;
        sprintf($left."%-".$size."s".$right."\n", $_);
    } @texts);

}

1;
