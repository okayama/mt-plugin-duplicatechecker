package DuplicateChecker::Plugin;
use strict;

use MT::Util qw( encode_html );

sub _cb_tp_edit_entry_check_duplicate {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $plugin = MT->component( 'DuplicateChecker' );
    my $blog = $app->blog;
    my $scope = 'blog:' . $blog->id;
    return unless $plugin->get_config_value( 'is_active', $scope );
    my $class = $app->param( '_type' );
    my ( %terms, %args );
    $terms{ blog_id } = $blog->id;
    if ( my $entry_title = $param->{ title } ) {
        $terms{ title } = $entry_title;
    }
    if ( my $entry_id = $app->param( 'id' ) ) {
        $terms{ id } = { 'not' => $entry_id };
    }
    my $duplicate_entry = MT->model( $class )->load( \%terms, \%args );
    if ( $duplicate_entry ) {
        if ( my $pointer_field = $tmpl->getElementById( 'header_include' ) ) {
            my $duplicate_entry_title = $duplicate_entry->title;
            my $duplicate_entry_id = $duplicate_entry->id;
            my $duplicate_entry_blog_id = $duplicate_entry->blog_id;
            my $duplicate_entry_class = $duplicate_entry->class;
            my $duplicate_edit_url = $app->base . $app->uri( mode => 'view',
                                                             args => {
                                                                _type => $duplicate_entry_class,
                                                                blog_id => $duplicate_entry_blog_id,
                                                                id => $duplicate_entry_id,
                                                             }
                                                           );
            my $duplicate_edit_link = '<a href="' . $duplicate_edit_url . '" target="_blank">' . encode_html( $duplicate_entry_title ) . '</a>';
            my $nodeset = $tmpl->createElement( 'setvarblock', { name => 'system_msg',
                                                                 append => 1,
                                                               }
                                              );
            my $innerHTML = <<MTML;
<mtapp:statusmsg
   id="title-is-duplicate"
   class="alert">
  <__trans_section component="DuplicateChecker">
    <__trans phrase="Is duplicate?: [_1]" params="$duplicate_edit_link">
  </__trans_section>
</mtapp:statusmsg>
MTML
            $nodeset->innerHTML( $innerHTML );
            $tmpl->insertBefore( $nodeset, $pointer_field );
        }
    }
}

1;
