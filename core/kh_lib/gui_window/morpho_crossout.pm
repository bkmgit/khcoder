package gui_window::morpho_crossout;
use base qw(gui_window);

use Tk;

use gui_widget::tani;
use gui_widget::hinshi;
use mysql_crossout;

use gui_window::morpho_crossout::csv;
use gui_window::morpho_crossout::spss;


#-------------#
#   GUI作製   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $mw->Toplevel;
	#$win->focus;
	$win->title(Jcode->new($self->label)->sjis);
	$self->{win_obj} = $win;

	my $lf = $win->LabFrame(
		-label => 'Option',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1);

	my $left = $lf->Frame()->pack(-fill => 'both', -expand => 1);
	# my $right = $lf->Frame()->pack(-side => 'right', -fill => 'x');
	
	# 集計単位の選択
	my $l1 = $left->Frame()->pack(-fill => 'x');
	$l1->Label(
		-text => Jcode->new('・集計単位の選択： ')->sjis,
		-font => "TKFN"
	)->pack(side => 'left');
	my %pack = (
			-anchor => 'e',
			-pady   => 2,
			-side   => 'left'
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $l1,
		pack   => \%pack
	);

	# 最小・最大出現数
	$left->Label(
		-text => Jcode->new('・最小/最大 出現数による語の取捨選択')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -pady => 5);
	my $l2 = $left->Frame()->pack(-fill => 'x');
	$l2->Label(
		-text => Jcode->new('　 　最小出現数：')->sjis,
		-font => "TKFN"
	)->pack(side => 'left');
	$self->{ent_min} = $l2->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left');
	$l2->Label(
		-text => Jcode->new('　 最大出現数：')->sjis,
		-font => "TKFN"
	)->pack(side => 'left');
	$self->{ent_max} = $l2->Entry(
		-font       => "TKFN",
		-width      => 6,
		-background => 'white',
	)->pack(-side => 'left');
	$self->{ent_min}->insert(0,'1');

	# 品詞による単語の取捨選択
	$left->Label(
		-text => Jcode->new('・品詞による語の取捨選択')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -pady => 5);
	my $l3 = $left->Frame()->pack(-fill => 'both',-expand => 1);
	$l3->Label(
		-text => Jcode->new('　　')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left',-fill => 'y',-expand => 1);
	%pack = (
			-anchor => 'w',
			-side   => 'left',
			-pady   => 1,
			-fill   => 'y',
			-expand => 1
	);
	$self->{hinshi_obj} = gui_widget::hinshi->open(
		parent => $l3,
		pack   => \%pack
	);
	my $l4 = $l3->Frame()->pack(-fill => 'x', -expand => 'y',-side => 'left');
	$l4->Button(
		-text => Jcode->new('全て選択')->sjis,
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj}->select_all;});}
	)->pack(-pady => 3);
	$l4->Button(
		-text => Jcode->new('クリア')->sjis,
		-width => 8,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->{hinshi_obj}->select_none;});}
	)->pack();
	
	# チェック部分
	my $cf = $win->LabFrame(
		-label => 'Check',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x');

	$cf->Label(
		-text => Jcode->new('出力される語の数：')->sjis,
		-font => "TKFN"
	)->pack(-anchor => 'w', -side => 'left');
	$cf->Button(
		-text => Jcode->new('チェック')->sjis,
		-font => "TKFN",
		-borderwidth => 1,
		-command => sub{ $mw->after(10,sub{$self->check;});}
	)->pack(-side => 'left', -padx => 2);
	$self->{ent_check} = $cf->Entry(
		-font       => "TKFN",
		-background => 'gray',
		-state      => 'disable'
	)->pack(-side => 'left',-fill => x);

	$win->Button(
		-text => Jcode->new('キャンセル')->sjis,
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2);

	$win->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->save;});}
	)->pack(-side => 'right');


	return $self;
}

#--------------#
#   チェック   #
sub check{
	my $self = shift;
	
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '品詞が1つも選択されていません。',
		);
		return 0;
	}
	
	
	my $check = mysql_crossout->new(
		tani   => $self->tani,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
	)->wnum;
	
	$self->{ent_check}->configure(-state => 'normal');
	$self->{ent_check}->delete(0,'end');
	$self->{ent_check}->insert(0,$check);
	$self->{ent_check}->configure(-state => 'disable');
}


#--------------#
#   アクセサ   #

sub min{
	my $self = shift;
	return $self->{ent_min}->get;
}
sub max{
	my $self = shift;
	return $self->{ent_max}->get;
}

sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}
sub hinshi{
	my $self = shift;
	return $self->{hinshi_obj}->selected;
}



1;