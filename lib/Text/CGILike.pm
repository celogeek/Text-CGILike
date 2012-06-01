package Text::CGILike;

# ABSTRACT: Wrapper to create text file using the CGI syntax

use strict;
use warnings;
use Moo;
use Text::Format;

# VERSION

our (@ISA, @EXPORT, %EXPORT_TAGS);

BEGIN {
    require Exporter;

    my @html2 = qw/start_html end_html hr h1 ul li br/;
    my @netscape = qw/center/;

    @ISA = qw(Exporter);
    @EXPORT = (@html2, @netscape);
    %EXPORT_TAGS = (
        'html2' => [@html2],
        'netscape' => [@netscape],
        'standard' => [@EXPORT]
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

sub br {
    my ($self) = _self_or_default(@_);
    return "\n";
}

sub center {
    my ($self, $text) = _self_or_default(@_);
    return $self->_center('','', $text);
}

sub ul {
    my ($self, @li) = _self_or_default(@_);
    return join("", @li);
}

sub li {
    my ($self, $li) = _self_or_default(@_);
    my $TF = Text::Format->new({firstIndent => 0, bodyIndent => 2, columns => $self->columns - 2});
    return "- " . $TF->format($li);
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
    my $TF = Text::Format->new({firstIndent => 0, bodyIndent => 0, columns => $size});

    my @texts = $TF->format($text);
    return join("\n", map {
        $_ = $TF->center($_);
        chomp;
        sprintf($left."%-".$size."s".$right."\n", $_);
    } @texts);

}

1;
