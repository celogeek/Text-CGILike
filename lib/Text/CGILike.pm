package Text::CGILike;

# ABSTRACT: Wrapper to create text file using the CGI syntax

use strict;
use warnings;
use Moo;
use Text::Format;

# VERSION

BEGIN {
    use parent 'Exporter';

    %EXPORT_TAGS = (
        ':html2' => [
            'h1' .. 'h6', qw/p br hr ol ul li dl dt dd menu code var strong em
              tt u i b blockquote pre img a address cite samp dfn html head
              base body Link nextid title meta kbd start_html end_html
              input Select option comment charset escapeHTML/
        ],
        ':html3' => [
            qw/div table caption th td TR Tr sup Sub strike applet Param nobr
              embed basefont style span layer ilayer font frameset frame script small big Area Map/
        ],
        ':html4' => [
            qw/abbr acronym bdo col colgroup del fieldset iframe
              ins label legend noframes noscript object optgroup Q
              thead tbody tfoot/
        ],
        ':netscape' => [qw/blink fontsize center/],
        ':form'     => [
            qw/textfield textarea filefield password_field hidden checkbox checkbox_group
              submit reset defaults radio_group popup_menu button autoEscape
              scrolling_list image_button start_form end_form startform endform
              start_multipart_form end_multipart_form isindex tmpFileName uploadInfo URL_ENCODED MULTIPART/
        ],
        ':cgi' => [
            qw/param upload path_info path_translated request_uri url self_url script_name
              cookie Dump
              raw_cookie request_method query_string Accept user_agent remote_host content_type
              remote_addr referer server_name server_software server_port server_protocol virtual_port
              virtual_host remote_ident auth_type http append
              save_parameters restore_parameters param_fetch
              remote_user user_name header redirect import_names put
              Delete Delete_all url_param cgi_error/
        ],
        ':ssl' => [qw/https/],
        ':cgi-lib' =>
          [qw/ReadParse PrintHeader HtmlTop HtmlBot SplitParam Vars/],
        ':html'     => [qw/:html2 :html3 :html4 :netscape/],
        ':standard' => [qw/:html2 :html3 :html4 :form :cgi/],
        ':push' =>
          [qw/multipart_init multipart_start multipart_end multipart_final/],
        ':all' => [qw/:html2 :html3 :netscape :form :cgi :internal :html4/]
    );
}

=attr DEFAULT_CLASS

To change columns using keywords

    require Text::CGILike;
    Text::CGILike->import(':standard');

    require Term::Size;
    my ($columns) = Term::Size::chars();
    $columns ||= 80;

    my ($TCGI) = Text::CGILike->DEFAULT_CLASS;
    $TCGI->columns($columns);

=cut

my $_DEFAULT_CLASS;

has 'columns' => (
    is      => 'rw',
    default => sub { 80 },
);

sub DEFAULT_CLASS {
    return _self_or_default(shift);
}

sub start_html {
    my ( $self, @texts ) = _self_or_default(@_);
    my $text;
    if ( @texts > 1 ) {
        my %p = @texts;
        $text = $p{-title} || "";
    }
    else {
        ($text) = @texts;
    }
    $self->{_start_html} = $text;
    return $self->hr . $self->_center( "# ", " #", $text ) . $self->hr . "\n";
}

sub end_html {
    my ($self) = _self_or_default(@_);
    my $text = $self->{_start_html} || "END";
    return "\n" . $self->hr . $self->_center( "# ", " #", $text ) . $self->hr;
}

sub meta {

    #no meta in text
    return "";
}

sub h1 {
    my ( $self, $title ) = _self_or_default(@_);
    return $self->_left( "# ", $title ) . $self->br();
}

sub hr {
    my ($self) = _self_or_default(@_);

    return "#" x ( $self->columns ) . "\n";
}

sub br {
    return "\n";
}

sub center {
    my ( $self, $text ) = _self_or_default(@_);
    return $self->_center( '', '', $text );
}

sub ul {
    my ( $self, @li ) = _self_or_default(@_);
    return join( "", grep { defined } @li );
}

sub li {
    my ( $self, $li ) = _self_or_default(@_);
    my $TF = Text::Format->new(
        { firstIndent => 0, bodyIndent => 2, columns => $self->columns - 2 } );
    return "- " . $TF->format($li);
}

### PRIVATE ###

sub _self_or_default {
    my ( $may_class, @param ) = @_;
    if ( ref $may_class eq __PACKAGE__ ) {
        return ( $may_class, @param );
    }
    else {
        $_DEFAULT_CLASS ||= __PACKAGE__->new;
        return ( $_DEFAULT_CLASS, $may_class, @param );
    }
}

sub _center {
    my $self = shift;
    my ( $left, $right, $text ) = @_;
    $left  = "" unless defined $left;
    $right = "" unless defined $right;

    my $size = $self->columns - length($left) - length($right);
    my $TF   = Text::Format->new(
        { firstIndent => 0, bodyIndent => 0, columns => $size } );

    my @texts = $TF->format($text);
    return join(
        "",
        map {
            $_ = $TF->center($_);
            chomp;
            sprintf( $left . "%-" . $size . "s" . $right . "\n", $_ );
        } @texts
    );

}

sub _left {
    my $self = shift;
    my ( $left, $text ) = @_;
    $left = "" unless defined $left;

    my $size = $self->columns - length($left);
    my $TF   = Text::Format->new(
        { firstIndent => 0, bodyIndent => 0, columns => $size } );

    my @texts = $TF->format($text);
    return $left . join( "" . $left, @texts );

}

1;

__END__

=head1 SEE ALSO

L<CGI>

